extends Node

var chunks: Dictionary = {} # key: Vector2i(chunk_pos), value: Array[Array[Cell]]
const CHUNK_SIZE: int = 8
var global_seed: int = randi()

var tilemap_layers: Dictionary[String, TileMapLayer] = {
	"base": null
}

var cell_terrain_type: Dictionary = {
	Cell.CellType.NONE: -1,
	Cell.CellType.SOFT_WALL: 0,
	Cell.CellType.GROUND: 1,
}

func generate_debug_chunk_at_global(chunk_pos: Vector2i, tilemap: TileMapLayer) -> void:		
	create_chunk(chunk_pos)
	var chunk = get_chunk(chunk_pos)
	for y in CHUNK_SIZE:
		for x in CHUNK_SIZE:
			chunk[y][x].type = Cell.CellType.GROUND
			chunk[y][x].health = 3
			chunk[y][x].destroyed.connect(_on_cell_destroyed.bind(tilemap))
	
	_update_chunk_visuals(chunk_pos, tilemap)

func create_chunk(chunk_pos: Vector2i) -> Array:
	var chunk: Array = []
	for y in CHUNK_SIZE:
		var row: Array = []
		for x in CHUNK_SIZE:
			var cell_pos: Vector2i = chunk_pos * CHUNK_SIZE + Vector2i(x, y)
			var cell: Cell = Cell.new(cell_pos)
			cell.type = Cell.CellType.NONE
			row.append(cell)
		chunk.append(row)
		
	chunks[chunk_pos] = chunk
	return chunks[chunk_pos]

func cell_pos_to_chunk(cell_pos: Vector2i) -> Vector2i:
	return Vector2i(
		int(floor(float(cell_pos.x) / CHUNK_SIZE)),
		int(floor(float(cell_pos.y) / CHUNK_SIZE))
	)

func get_chunk(chunk_pos: Vector2i) -> Array:
	if chunks.has(chunk_pos):
		return chunks[chunk_pos]
	return []

func get_cell(cell_pos: Vector2i) -> Cell:
	var chunk: Array = get_chunk(cell_pos_to_chunk(cell_pos))
	if chunk == []:
		return null
	var local_pos: Vector2i = cell_pos % CHUNK_SIZE
	var cell: Cell = chunk[local_pos.y][local_pos.x]
	return cell

func set_cell(cell_pos: Vector2i, new_cell: Cell, tilemap: TileMapLayer) -> void:
	var chunk: Array = get_chunk(cell_pos_to_chunk(cell_pos))
	if chunk == []:
		chunk = create_chunk(cell_pos_to_chunk(cell_pos))
	
	var local_pos: Vector2i = cell_pos % CHUNK_SIZE
	chunk[local_pos.y][local_pos.x] = new_cell
	_update_cell_tiling(cell_pos, tilemap)

func world_to_cell(world_pos: Vector2, tilemap: TileMapLayer) -> Vector2i:
	"""
	Converts world position to cell/tile coordinates.
	"""
	return tilemap.local_to_map(world_pos)

func cell_to_world(cell_pos: Vector2i, tilemap: TileMapLayer) -> Vector2:
	"""
	Converts cell/tile coordinates to world position (center of tile).
	"""
	return tilemap.map_to_local(cell_pos)

func spawn_cell_blob(center_world_pos: Vector2, radius: float, cell_type: Cell.CellType, tilemap: TileMapLayer) -> Array[Vector2i]:
	"""
	Spawns a circular blob of cells around a world position.
	Returns array of cell positions that were created.
	"""
	var center_tile = tilemap.local_to_map(center_world_pos)
	var created_cells: Array[Vector2i] = []
	var radius_squared = radius * radius
	
	# Calculate tile radius to check
	var tile_radius = int(ceil(radius / tilemap.tile_set.tile_size.x))
	
	for y in range(-tile_radius, tile_radius + 1):
		for x in range(-tile_radius, tile_radius + 1):
			var offset = Vector2i(x, y)
			var check_pos = center_tile + offset
			
			# Check if within circular radius
			var world_check_pos = tilemap.map_to_local(check_pos)
			var dist_squared = center_world_pos.distance_squared_to(world_check_pos)
			
			if dist_squared <= radius_squared:
				var new_cell = Cell.new(check_pos)
				new_cell.type = cell_type
				new_cell.health = 3
				new_cell.destroyed.connect(_on_cell_destroyed.bind(tilemap))
				
				set_cell(check_pos, new_cell, tilemap)
				created_cells.append(check_pos)
	
	return created_cells

func spawn_irregular_blob(center_world_pos: Vector2, radius: float, cell_type: Cell.CellType, tilemap: TileMapLayer, noise_scale: float = 0.2, noise_threshold: float = 0.3) -> Array[Vector2i]:
	"""
	Spawns an irregularly shaped blob using noise.
	
	Parameters:
	- noise_scale: Lower = smoother edges, Higher = more jagged (0.1 - 0.5 recommended)
	- noise_threshold: Higher = smaller blob, Lower = larger blob (-0.5 to 0.5 recommended)
	"""
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_scale
	
	var center_tile = tilemap.local_to_map(center_world_pos)
	var created_cells: Array[Vector2i] = []
	var radius_squared = radius * radius
	
	var tile_radius = int(ceil(radius / tilemap.tile_set.tile_size.x))
	
	for y in range(-tile_radius, tile_radius + 1):
		for x in range(-tile_radius, tile_radius + 1):
			var offset = Vector2i(x, y)
			var check_pos = center_tile + offset
			
			var world_check_pos = tilemap.map_to_local(check_pos)
			var dist_squared = center_world_pos.distance_squared_to(world_check_pos)
			
			if dist_squared <= radius_squared:
				# Sample noise at this position
				var noise_value = noise.get_noise_2d(check_pos.x, check_pos.y)
				
				# Blend noise with distance for more natural falloff
				var dist_factor = 1.0 - (sqrt(dist_squared) / radius)
				var combined = noise_value + (dist_factor * 0.5)
				
				if combined > noise_threshold:
					var new_cell = Cell.new(check_pos)
					new_cell.type = cell_type
					new_cell.health = 3
					new_cell.destroyed.connect(_on_cell_destroyed.bind(tilemap))
					
					set_cell(check_pos, new_cell, tilemap)
					created_cells.append(check_pos)
	
	return created_cells
	
func spawn_cell_border(
	top_left_tile: Vector2i,
	width: int,
	height: int,
	cell_type: Cell.CellType,
	thickness: int = 1,
	tilemap: TileMapLayer = null
) -> Array[Vector2i]:
	"""
	Spawns only the border (outline) of a rectangle made of cells.

	Parameters:
	- top_left_tile: Top-left cell position (inclusive)
	- width, height: Size in cells (must be >= 2 * thickness)
	- cell_type: Type of cell to place on the border
	- thickness: How many cells thick the border should be (1 = single line, 2 = double, etc.)
	- tilemap: The TileMapLayer to update (optional if you have a default one)

	Returns: Array of all cell positions that were created/modified
	"""
	if width < 2 * thickness or height < 2 * thickness:
		push_warning("Rectangle too small for border thickness %d (min size: %d x %d)" % [thickness, 2*thickness, 2*thickness])
		return []

	var created_cells: Array[Vector2i] = []

	# Helper lambda to safely spawn a cell
	var spawn := func(pos: Vector2i):
		var cell := get_cell(pos)
		if cell == null or cell.type == Cell.CellType.NONE:
			var new_cell = Cell.new(pos)
			new_cell.type = cell_type
			new_cell.health = 3
			new_cell.destroyed.connect(_on_cell_destroyed.bind(tilemap))
			set_cell(pos, new_cell, tilemap)
			created_cells.append(pos)

	# Top border
	for t in range(thickness):
		for x in range(width):
			spawn.call(top_left_tile + Vector2i(x, t))

	# Bottom border
	for t in range(thickness):
		for x in range(width):
			spawn.call(top_left_tile + Vector2i(x, height - 1 - t))

	# Left border (excluding corners already done by top/bottom)
	for t in range(thickness):
		for y in range(thickness, height - thickness):
			spawn.call(top_left_tile + Vector2i(t, y))

	# Right border (excluding corners)
	for t in range(thickness):
		for y in range(thickness, height - thickness):
			spawn.call(top_left_tile + Vector2i(width - 1 - t, y))

	return created_cells
	
func generate_blob_chain(start_pos: Vector2, initial_direction_deg: float, angle_freedom_deg: float, step_distance: float, num_steps: int, radius: float, noise_scale: float, noise_threshold: float, cell_type: Cell.CellType, tilemap: TileMapLayer,):
	"""
	Spawns an initial irregular blob at start_pos, then generates a chain of additional blobs
	by "walking" step_distance pixels in a direction that starts at initial_direction_deg
	and deviates randomly within ±angle_freedom_deg/2 degrees per step for organic paths.

	- num_steps: Number of additional blobs after the initial one (total blobs = num_steps + 1)
	- All other spawn_irregular_blob params can be overridden here.
	"""
	# Initial spawn
	spawn_irregular_blob(start_pos, radius, cell_type, tilemap, noise_scale, noise_threshold)

	var current_pos: Vector2 = start_pos
	var current_dir_rad: float = deg_to_rad(initial_direction_deg)

	for i in range(num_steps):
		# Add random deviation for natural wandering
		var deviation_rad: float = randf_range(
			-deg_to_rad(angle_freedom_deg * 0.5),
			deg_to_rad(angle_freedom_deg * 0.5)
		)
		current_dir_rad += deviation_rad
		
		# Move forward
		var move_vec: Vector2 = Vector2(cos(current_dir_rad), sin(current_dir_rad)) * step_distance
		current_pos += move_vec
		
		# Spawn next blob
		spawn_irregular_blob(current_pos, radius, cell_type, tilemap, noise_scale, noise_threshold)

func spawn_scattered_cells(center_world_pos: Vector2, radius: float, cell_type: Cell.CellType, tilemap: TileMapLayer, density: float = 0.5) -> Array[Vector2i]:
	"""
	Spawns randomly scattered cells in a circular area.
	
	Parameters:
	- density: 0.0 to 1.0, probability of each cell spawning
	"""
	var center_tile = tilemap.local_to_map(center_world_pos)
	var created_cells: Array[Vector2i] = []
	var radius_squared = radius * radius
	
	var tile_radius = int(ceil(radius / tilemap.tile_set.tile_size.x))
	
	for y in range(-tile_radius, tile_radius + 1):
		for x in range(-tile_radius, tile_radius + 1):
			var offset = Vector2i(x, y)
			var check_pos = center_tile + offset
			
			var world_check_pos = tilemap.map_to_local(check_pos)
			var dist_squared = center_world_pos.distance_squared_to(world_check_pos)
			
			if dist_squared <= radius_squared and randf() < density:
				var new_cell = Cell.new(check_pos)
				new_cell.type = cell_type
				new_cell.health = 3
				new_cell.destroyed.connect(_on_cell_destroyed.bind(tilemap))
				
				set_cell(check_pos, new_cell, tilemap)
				created_cells.append(check_pos)
	
	return created_cells

func spawn_cell_rect(top_left_tile: Vector2i, width: int, height: int, cell_type: Cell.CellType, tilemap: TileMapLayer) -> Array[Vector2i]:
	"""
	Spawns a rectangular area of cells.
	Returns array of cell positions that were created.
	"""
	var created_cells: Array[Vector2i] = []
	
	for y in range(height):
		for x in range(width):
			var cell_pos = top_left_tile + Vector2i(x, y)
			var new_cell = Cell.new(cell_pos)
			new_cell.type = cell_type
			new_cell.health = 3
			new_cell.destroyed.connect(_on_cell_destroyed.bind(tilemap))
			
			set_cell(cell_pos, new_cell, tilemap)
			created_cells.append(cell_pos)
	
	return created_cells

func destroy_cell(cell_pos: Vector2i, tilemap: TileMapLayer) -> bool:
	"""
	Destroys a cell at the given position. Returns true if successful.
	"""
	var cell = get_cell(cell_pos)
	if not cell or cell.type == Cell.CellType.NONE:
		return false
	
	var new_cell = Cell.new(cell_pos)
	new_cell.type = Cell.CellType.NONE
	
	var chunk_pos := cell_pos_to_chunk(cell_pos)
	var local_pos := cell_pos % CHUNK_SIZE
	var chunk : Array = chunks[chunk_pos]
	chunk[local_pos.y][local_pos.x] = new_cell
	
	_update_tilemap_tile(cell_pos, new_cell, tilemap)
	return true

func _on_cell_destroyed(cell_pos: Vector2i, _flag: int, tilemap: TileMapLayer) -> void:
	destroy_cell(cell_pos, tilemap)

func _update_tilemap_tile(cell_pos: Vector2i, cell: Cell, tilemap: TileMapLayer) -> void:
	var source_id := 0
	var atlas_coords := _tile_coords_for_cell(cell)
	tilemap.set_cell(cell_pos, source_id, atlas_coords)

func _update_cell_tiling(cell_pos: Vector2i, tilemap: TileMapLayer) -> void:
	var cell: Cell = get_cell(cell_pos)
	if cell == null:
		return
	
	var directions: Array[Vector2i] = [
		Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1),
		Vector2i(0, -1),                  Vector2i(0, 1),
		Vector2i(1, -1),  Vector2i(1, 0), Vector2i(1, 1)
	]
	
	if cell.type == Cell.CellType.NONE:
		for dir in directions:
			var adj_pos: Vector2i = cell_pos + dir
			var adj_cell: Cell = get_cell(adj_pos)
			if adj_cell != null && adj_cell.type != Cell.CellType.NONE && cell_terrain_type.has(adj_cell.type):
				var terrain: int = cell_terrain_type[adj_cell.type]
				tilemap.set_cells_terrain_connect([adj_pos], 0, terrain)
	else:
		if cell_terrain_type.has(cell.type):
			var terrain: int = cell_terrain_type[cell.type]
			tilemap.set_cells_terrain_connect([cell_pos], 0, terrain)

func _update_chunk_visuals(chunk_pos: Vector2i, tilemap: TileMapLayer) -> void:
	for y in CHUNK_SIZE:
		for x in CHUNK_SIZE:
			var cell_pos: Vector2i = chunk_pos * CHUNK_SIZE + Vector2i(x, y)
			_update_cell_tiling(cell_pos, tilemap)

func _tile_coords_for_cell(cell: Cell) -> Vector2i:
	match cell.type:
		Cell.CellType.SOFT_WALL: return Vector2i(0, 0)
		Cell.CellType.GROUND: return Vector2i(1, 0)
	return Vector2i(-1, -1) # empty
