extends Node

@onready var tile_map_layer: TileMapLayer = $Terrain
@onready var tile_set: TileSet = tile_map_layer.tile_set

var region: Rect2i = Rect2i(0, 0, 50, 50)

# Signal emitted when terrain is modified
signal terrain_updated(region: Rect2i)

func _ready() -> void:
	# Validate TileSet setup
	if not tile_set:
		push_error("TileMapLayer has no TileSet assigned!")
		return
	if tile_set.get_terrains_count(0) < 2:
		push_error("TileSet must have at least two terrain sets (walls and ground)!")
		return
	if tile_set.get_physics_layers_count() < 1:
		push_warning("TileSet has no physics layers; walls won't collide.")
	if tile_set.get_navigation_layers_count() < 1:
		push_warning("TileSet has no navigation layers; pathfinding may not work.")
		
	call_deferred("populate_with_noise", region)
	await apply_cellular_automata(region, 1, 4, 5, 0.20)	

# --- Tile Creation ---

func create_wall_tiles(cells: Array[Vector2i], terrain_index: int = 0) -> void:
	if cells.is_empty():
		return
	# Batch clear conflicting ground tiles
	var to_clear: Array[Vector2i] = []
	for cell in cells:
		var tile_data = tile_map_layer.get_cell_tile_data(cell)
		if tile_data and tile_data.terrain == 1:
			to_clear.append(cell)
	if not to_clear.is_empty():
		tile_map_layer.set_cells_terrain_connect(to_clear, 0, -1)  # Clear using invalid terrain
	# Place walls
	tile_map_layer.set_cells_terrain_connect(cells, 0, terrain_index)

func create_ground_tiles(cells: Array[Vector2i], terrain_index: int = 1) -> void:
	if cells.is_empty():
		return
	# Batch clear conflicting wall tiles
	var to_clear: Array[Vector2i] = []
	for cell in cells:
		var tile_data = tile_map_layer.get_cell_tile_data(cell)
		if tile_data and tile_data.terrain == 0:
			to_clear.append(cell)
	if not to_clear.is_empty():
		tile_map_layer.set_cells_terrain_connect(to_clear, 0, -1)
	# Place ground
	tile_map_layer.set_cells_terrain_connect(cells, 0, terrain_index)

func create_single_tile(coord: Vector2i, is_wall: bool, terrain_index: int = -1) -> void:
	if is_wall:
		create_wall_tiles([coord])
	else:
		create_ground_tiles([coord])

# --- Tile Deletion ---

func delete_tiles(cells: Array[Vector2i]) -> void:
	for cell in cells:
		tile_map_layer.erase_cell(cell)
	# Update surrounding area to fix autotiling
	var region: Rect2i = get_bounding_rect(cells).grow(1)
	update_autotile_square(region)

func delete_single_tile(coord: Vector2i) -> void:
	delete_tiles([coord])

# --- Autotiling Updates ---

func update_autotile_square(region: Rect2i) -> void:
	# Get all cells in the region
	var all_cells: Array[Vector2i] = []
	for x in range(region.position.x, region.end.x):
		for y in range(region.position.y, region.end.y):
			var cell = Vector2i(x, y)
			if tile_map_layer.get_cell_source_id(cell) != -1:
				all_cells.append(cell)
	
	# Separate into wall and ground cells
	var wall_cells: Array[Vector2i] = []
	var ground_cells: Array[Vector2i] = []
	for cell in all_cells:
		var tile_data: TileData = tile_map_layer.get_cell_tile_data(cell)
		if tile_data:
			if tile_data.terrain == 0:
				wall_cells.append(cell)
			elif tile_data.terrain == 1:
				ground_cells.append(cell)
	
	# Reconnect terrains
	if wall_cells.size() > 0:
		tile_map_layer.set_cells_terrain_connect(wall_cells, 0, 0)
	if ground_cells.size() > 0:
		tile_map_layer.set_cells_terrain_connect(ground_cells, 0, 1)
	
	emit_signal("terrain_updated", region)

# --- Noise Population ---

func populate_with_noise(region: Rect2i, wall_probability: float = 0.5) -> void:
	var wall_cells: Array[Vector2i] = []
	var ground_cells: Array[Vector2i] = []
	for x in range(region.position.x, region.end.x):
		for y in range(region.position.y, region.end.y):
			var cell = Vector2i(x, y)
			if randf() < wall_probability:
				wall_cells.append(cell)
			else:
				ground_cells.append(cell)
	create_wall_tiles(wall_cells)
	create_ground_tiles(ground_cells)
	update_autotile_square(region)

# --- Cellular Automata ---

## Composable helper functions for CA

# Get 8 Moore neighbors, filtering those within the map (assuming infinite ground outside, but for simplicity, only count existing cells)
func get_neighbors(cell: Vector2i) -> Array[Vector2i]:
	var offsets = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0),                  Vector2i(1, 0),
		Vector2i(-1, 1),  Vector2i(0, 1), Vector2i(1, 1)
	]
	var neighbors: Array[Vector2i] = []
	for offset in offsets:
		var neigh = cell + offset
		neighbors.append(neigh)  # Count even if empty (treat empty as ground)
	return neighbors

# Count wall neighbors
func count_wall_neighbors(cell: Vector2i) -> int:
	var count = 0
	for neigh in get_neighbors(cell):
		var tile_data: TileData = tile_map_layer.get_cell_tile_data(neigh)
		if tile_data and tile_data.terrain == 0:
			count += 1
	return count

# Compute next state: true = wall, false = ground
func compute_next_state(cell: Vector2i, wall_stay_threshold: int, ground_to_wall_threshold: int) -> bool:
	var tile_data: TileData = tile_map_layer.get_cell_tile_data(cell)
	var is_wall = tile_data and tile_data.terrain == 0
	var wall_count = count_wall_neighbors(cell)
	if is_wall:
		return wall_count >= wall_stay_threshold
	else:
		return wall_count >= ground_to_wall_threshold
		
# Helper to collect wall/ground cells in a strip (e.g., column or row plus adjacents)
func collect_terrain_in_strip(region: Rect2i, index: int, is_vertical: bool = true) -> Dictionary:
	var wall_cells: Array[Vector2i] = []
	var ground_cells: Array[Vector2i] = []
	var min_idx: int
	var max_idx: int
	if is_vertical:
		min_idx = max(region.position.x, index - 1)
		max_idx = min(region.end.x - 1, index + 1)
		for x in range(min_idx, max_idx + 1):
			for y in range(region.position.y, region.end.y):
				var cell = Vector2i(x, y)
				var tile_data = tile_map_layer.get_cell_tile_data(cell)
				if tile_data:
					if tile_data.terrain == 0:
						wall_cells.append(cell)
					elif tile_data.terrain == 1:
						ground_cells.append(cell)
	else:  # horizontal
		min_idx = max(region.position.y, index - 1)
		max_idx = min(region.end.y - 1, index + 1)
		for y in range(min_idx, max_idx + 1):
			for x in range(region.position.x, region.end.x):
				var cell = Vector2i(x, y)
				var tile_data = tile_map_layer.get_cell_tile_data(cell)
				if tile_data:
					if tile_data.terrain == 0:
						wall_cells.append(cell)
					elif tile_data.terrain == 1:
						ground_cells.append(cell)
	return {"walls": wall_cells, "grounds": ground_cells}
	
# Helper to get all cells in a specific column (for vertical lines)
func get_column_cells(region: Rect2i, x: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in range(region.position.y, region.end.y):
		cells.append(Vector2i(x, y))
	return cells

# Helper to get all cells in a specific row (for horizontal lines)
func get_row_cells(region: Rect2i, y: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x in range(region.position.x, region.end.x):
		cells.append(Vector2i(x, y))
	return cells

# Apply CA with progressive directional update (left-to-right column sweep)
# time_scale: <=0 for instant (no delays), >0 for speed multiplier (higher = faster)
# delay_per_column: base delay in seconds per column; actual = delay_per_column / time_scale
# direction: only "left_to_right" implemented; can extend to others
func apply_cellular_automata(region: Rect2i, iterations: int = 5, wall_stay_threshold: int = 4, ground_to_wall_threshold: int = 5, time_scale: float = 0.0, direction: String = "left_to_right") -> void:
	var min_x = region.position.x
	var max_x = region.end.x - 1
	var min_y = region.position.y
	var max_y = region.end.y - 1
	
	var base_delay_per_line: float = 0.05  # Adjustable base delay for visibility
	var is_vertical_sweep = direction in ["left_to_right", "right_to_left"]
	
	for iter in range(iterations):
		var start_idx: int
		var end_idx: int
		var step: int = 1
		if direction == "left_to_right":
			start_idx = min_x
			end_idx = max_x
		elif direction == "right_to_left":
			start_idx = max_x
			end_idx = min_x
			step = -1
		elif direction == "top_to_bottom":
			start_idx = min_y
			end_idx = max_y
		elif direction == "bottom_to_top":
			start_idx = max_y
			end_idx = min_y
			step = -1
		else:
			push_error("Unsupported direction: " + direction)
			return
		
		var current_idx = start_idx
		while true:
			# Get cells in the current line
			var line_cells: Array[Vector2i]
			if is_vertical_sweep:
				line_cells = get_column_cells(region, current_idx)
			else:
				line_cells = get_row_cells(region, current_idx)
			
			# Compute next states for the line
			var new_wall_cells: Array[Vector2i] = []
			var new_ground_cells: Array[Vector2i] = []
			for cell in line_cells:
				if compute_next_state(cell, wall_stay_threshold, ground_to_wall_threshold):
					new_wall_cells.append(cell)
				else:
					new_ground_cells.append(cell)
			
			# Erase the current line
			tile_map_layer.set_cells_terrain_connect(line_cells, 0, -1)
			
			# Get adjacent strips for reconnection (includes the current line position, but since erased, only adjacents have cells)
			var adjacent_terrain = collect_terrain_in_strip(region, current_idx, is_vertical_sweep)
			
			# Add new line cells to the adjacent lists for full strip connection
			adjacent_terrain["walls"].append_array(new_wall_cells)
			adjacent_terrain["grounds"].append_array(new_ground_cells)
			
			# Reconnect the full strip (adjacents + new line)
			if not adjacent_terrain["walls"].is_empty():
				tile_map_layer.set_cells_terrain_connect(adjacent_terrain["walls"], 0, 0)
			if not adjacent_terrain["grounds"].is_empty():
				tile_map_layer.set_cells_terrain_connect(adjacent_terrain["grounds"], 0, 1)
			
			# Emit wave progress signal
			emit_signal("wave_advanced", direction, current_idx)
			
			# Delay if time_scale > 0
			if time_scale > 0:
				var actual_delay = base_delay_per_line / time_scale
				await get_tree().create_timer(actual_delay).timeout
			
			# Advance to next line
			if current_idx == end_idx:
				break
			current_idx += step
		
		# Optional: Full update after each iteration if needed, but strip updates should suffice
		# update_autotile_square(region)

# --- Helper Functions ---

func get_dominant_terrain(cells: Array[Vector2i], terrain_set: int) -> int:
	# Count terrain indices in the given cells
	var terrain_counts: Dictionary = {}
	for cell in cells:
		var tile_data: TileData = tile_map_layer.get_cell_tile_data(cell)
		if tile_data and tile_data.terrain_set == terrain_set:
			var terrain_idx: int = tile_data.terrain
			terrain_counts[terrain_idx] = terrain_counts.get(terrain_idx, 0) + 1
	
	# Return the most frequent terrain index, or 0 if none found
	var max_count: int = 0
	var dominant_terrain: int = 0
	for terrain_idx in terrain_counts:
		if terrain_counts[terrain_idx] > max_count:
			max_count = terrain_counts[terrain_idx]
			dominant_terrain = terrain_idx
	return dominant_terrain

func get_bounding_rect(cells: Array[Vector2i]) -> Rect2i:
	# Calculate the bounding rectangle for a list of cells
	if cells.is_empty():
		return Rect2i(0, 0, 0, 0)
	var min_pos: Vector2i = cells[0]
	var max_pos: Vector2i = cells[0]
	for cell in cells:
		min_pos.x = min(min_pos.x, cell.x)
		min_pos.y = min(min_pos.y, cell.y)
		max_pos.x = max(max_pos.x, cell.x)
		max_pos.y = max(max_pos.y, cell.y)
	return Rect2i(min_pos, max_pos - min_pos + Vector2i(1, 1))
