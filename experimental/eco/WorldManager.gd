extends Node

var tilemap: TileMapLayer

var chunks: Dictionary[Vector2i, Chunk] = {}

var terrain_definitions: Dictionary = {}
	
func initialize(tml: TileMapLayer) -> void:
	_setup_terrain_definitions()
	
	tilemap = tml
	
	if tilemap:
		_sync_with_tilemap()
	
		
func _process(delta) -> void:
	for chunk in chunks.values():
		chunk.process(delta)
	
func _setup_terrain_definitions() -> void:
	# define what each terrain set/ID means in gameplay terms
	
	terrain_definitions[0] = {
		1: {"name": "dirt_wall", "type": Cell.Type.WALL, "nutrition": 0.0, "moisture": 0.0, "traversability": 0.0, "health": 10.0, "max_health": 10.0, "indestructible": false},
		0: {"name": "dirt_path", "type": Cell.Type.GROUND, "nutrition": 15.0, "moisture": 5.0, "traversability": 1.0, "health": 10.0, "max_health": 10.0, "indestructible": true},
	}
	
	# add more terrain definitions here...
	
func _sync_with_tilemap() -> void:
	# create cell data for all tiles in the tilemaplayer
	var used_cells: Array[Vector2i] = tilemap.get_used_cells()
	
	for tile_pos in used_cells:
		var chunk_pos = world_to_chunk(Vector2(tile_pos))
		var local_pos = world_to_local(Vector2(tile_pos))
		
		if not chunks.has(chunk_pos):
			chunks[chunk_pos] = Chunk.new(chunk_pos)
			
		var tile_data = tilemap.get_cell_tile_data(tile_pos)
		if not tile_data:
			continue
			
		var terrain_set = tile_data.terrain_set
		var terrain = tile_data.terrain
		
		var cell = _create_cell_from_terrain(terrain_set, terrain)
		chunks[chunk_pos].set_cell(local_pos.x, local_pos.y, cell)

func _create_cell_from_terrain(terrain_set: int, terrain: int) -> Cell:
	# create a cell with properties based on terrain set/id
	var cell = Cell.new(terrain_set, terrain)
	
	if terrain_set in terrain_definitions and terrain in terrain_definitions[terrain_set]:
		var def: Dictionary = terrain_definitions[terrain_set][terrain]
		
		cell.name = def.get("name", "")
		cell.nutrition = def.get("nutrition", 0.0)
		cell.moisture = def.get("moisture", 0.0)
		cell.traversability = def.get("traversability", 1.0)
		cell.health = def.get("health", 0.0)
		cell.max_health = def.get("max_health", 0.0)
		cell.indestructible = def.get("indestructible", false)
		cell.type = def.get("type", Cell.Type.NULL)
	else:
		# defaults in case the definition is not defined
		cell.nutrition = 0.0
		cell.moisture = 0.0
		cell.health = 0.0
		cell.max_health = 0.0
		cell.traversability = 0.0
		cell.type = Cell.Type.NULL
	return cell



# COORDINATE CONVERSION # -----------------------------------------------------------------------------

func world_to_chunk(world_pos: Vector2) -> Vector2i:
	# convert world position to chunk position
	# chunk position is represented as units where each unit represents 64 cells in an 8x8 square
	
	return Vector2i(
		floori(world_pos.x / Chunk.CHUNK_SIZE),
		floori(world_pos.y / Chunk.CHUNK_SIZE),
	)

func world_to_local(world_pos: Vector2) -> Vector2i:
	# convert world position to local chunk position
	# chunks are split into 64 units, which are represented by a local coordinate from (0, 0) to (7, 7)
	
	var tile_x: int = floori(world_pos.x)
	var tile_y: int = floori(world_pos.y)
	var cx = tile_x % Chunk.CHUNK_SIZE
	var cy = tile_y % Chunk.CHUNK_SIZE
	if cx < 0: cx += Chunk.CHUNK_SIZE
	if cy < 0: cy += Chunk.CHUNK_SIZE
	return Vector2i(cx, cy)
	
func world_to_tile(world_pos: Vector2) -> Vector2i:
	# convert world position to tile position
	
	return Vector2i(floori(world_pos.x), floori(world_pos.y))	

func chunk_to_world(chunk_pos: Vector2i, local_pos: Vector2i = Vector2i.ZERO) -> Vector2:
	# convert chunk + local coords to world tile position
	
	return Vector2(
		(chunk_pos.x * Chunk.CHUNK_SIZE + local_pos.x) * Cell.CELL_SIZE,
		(chunk_pos.y * Chunk.CHUNK_SIZE + local_pos.y) * Cell.CELL_SIZE
	)




# CELL ACCESS # ---------------------------------------------------------------------------------------

func get_cell(world_pos: Vector2i) -> Cell:
	# get cell at world position
	
	var chunk_pos: Vector2i = world_to_chunk(world_pos)
	var local_pos: Vector2i = world_to_local(world_pos)
	
	if not chunks.has(chunk_pos):
		return null
		
	return chunks[chunk_pos].get_cell(local_pos)
		
func set_cell_terrain(world_pos: Vector2i, terrain_set: int, terrain: int) -> void:
	# set a cell's terrain and trigger auto tiling
	
	var chunk_pos: Vector2i = world_to_chunk(world_pos)
	var local_pos: Vector2i = world_to_local(world_pos)
	
	if not chunks.has(chunk_pos):
		chunks[chunk_pos] = Chunk.new(chunk_pos)
		
	var cell = _create_cell_from_terrain(terrain_set, terrain)
	chunks[chunk_pos].set_cell(local_pos.x, local_pos.y, cell)
	
	update_tilemap_from_cell(world_pos)
	
func update_tilemap_from_cell(world_pos: Vector2) -> void:
	# sync TileMapLayer with Cell dat and trigger auta tiling
	
	var tile_pos: Vector2i = world_to_tile(world_pos)
	var cell: Cell = get_cell(world_pos)
	
	# check case if cell is nonexistent, erase the tilemap version of it and update
	if not cell or cell.is_empty():
		tilemap.erase_cell(tile_pos)
		_update_surrounding_terrain(tile_pos)
		return
	
	# otherwise, do the autotiling per the cell's terrain set/id data
	tilemap.set_cells_terrain_connect([tile_pos], cell.terrain_set, cell.terrain, false)
	_update_surrounding_terrain(tile_pos)
	
func _update_surrounding_terrain(center_pos: Vector2i) -> void:
	# update terrain tiles around a position to ensure auto tiling
	
	var neighbors = [
		Vector2i(center_pos.x - 1, center_pos.y),		# left
		Vector2i(center_pos.x + 1, center_pos.y),		# right
		Vector2i(center_pos.x, center_pos.y - 1),		# up
		Vector2i(center_pos.x, center_pos.y + 1),		# down
		Vector2i(center_pos.x - 1, center_pos.y - 1),	# top left
		Vector2i(center_pos.x + 1, center_pos.y - 1),	# top right
		Vector2i(center_pos.x - 1, center_pos.y + 1),	# bottom left
		Vector2i(center_pos.x + 1, center_pos.y + 1),	# bottom right
	]
	
	for neighbor_pos in neighbors:
		var neighbor_cell = get_cell(neighbor_pos)
		if neighbor_cell and not neighbor_cell.is_empty():
			# reapply terrain to trigger auto tiling
			tilemap.set_cells_terrain_connect(
				[neighbor_pos],
				neighbor_cell.terrain_set,
				neighbor_cell.terrain,
				false
			)





# utlity FUNCTIONS # -------------------------------------------------------------------------------

func get_cells_in_radius(center: Vector2, radius: int) -> Array[Cell]:
	# get all cells in a radius
	# useful for creature vision, fog of war, etc
	
	var result: Array[Cell] = []
	var center_tile = world_to_tile(center)
	
	for x in range(center_tile.x - radius, center_tile.x + radius + 1):
		for y in range(center_tile.y - radius, center_tile.y + radius + 1):
			var dist = center_tile.distance_to(Vector2i(x, y))
			if dist <= radius:
				var cell = get_cell(Vector2(x, y))
				if cell:
					result.append(cell)
					
	return result
	
func damage_cell(world_pos: Vector2, damage: float)	-> bool:
	# damage a cell. returns true if destroyed.
	
	var cell = get_cell(world_pos)
	if not cell:
		return false
		
	var destroyed = cell.take_damage(damage)
	
	if destroyed:
		var terrain_set = cell.terarin_set
		set_cell_terrain(world_pos, terrain_set, 0) # 0 because that is the reserved slot for a ground tileset for the terrain set
	
	return destroyed
	
func get_traversability_at(world_pos: Vector2) -> float:
	# get traversability value for this cell
	
	var cell = get_cell(world_pos)
	if not cell:
		return 1.0
	return cell.get_movement_modifier()
	
func is_cell_passable(world_pos: Vector2) -> bool:
	# check if a cel can be walked through
	var cell = get_cell(world_pos)
	if not cell:
		return true
	return cell.is_passable()
	
	
# chunk management # ------------------------------------------------------------------------	

func load_chunk(chunk_pos: Vector2i) -> void:
	# load or generate a new chunk if it doesn't exist
	if not chunks.has(chunk_pos):
		chunks[chunk_pos] = Chunk.new(chunk_pos)
	
func unload_chunk(chunk_pos: Vector2i) -> void:
	chunks.erase(chunk_pos)
	
func get_loaded_chunks() -> Array:
	return chunks.keys()
