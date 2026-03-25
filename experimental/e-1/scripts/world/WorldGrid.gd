extends Node
# AUTOLOAD AS WorldGrid

var width: int = 64
var height: int = 64
var _grid: Array[CellData] = []
var grid_size: Vector2
var tile_size: int = 16

signal cell_changed(coords: Vector2i) ## connects to worldrenderer to set a cell visually on the tilemaplayer
signal grid_loaded

func init_grid(w: int, h: int) -> void:
	width = w
	height = h
	grid_size.x = w
	grid_size.y = h
	_grid.clear()
	_grid.resize(w * h)
	for i in _grid.size():
		_grid[i] = CellData.new()
	grid_loaded.emit()
		
func get_cell(coords: Vector2i) -> CellData:
	if not _in_bounds(coords):
		
		return null
	return _grid[_idx(coords)]

func set_cell(coords: Vector2i, cell: CellData, reveal_area: bool = true) -> void:
	if not _in_bounds(coords):
		return
		
	var old_cell: CellData = _grid[_idx(coords)]
	var old_terrain: CellData.TerrainType = old_cell.terrain
	
	_grid[_idx(coords)] = cell # replace with new celldata
	
	_handle_terrain_change(coords, old_terrain, cell.terrain)
	
	cell_changed.emit(coords)
	
	_set_invisible(coords, get_cell(coords))
	
	
	

func mutate(coords: Vector2i, property: String, value: Variant) -> void:
	var cell = get_cell(coords)
	if cell and property in cell:
		cell.set(property, value)
		cell_changed.emit(coords)
		
const CARDINAL_DIRS = {
	"N":  Vector2i( 0, -1),
	"S":  Vector2i( 0,  1),
	"E":  Vector2i( 1,  0),
	"W":  Vector2i(-1,  0),
}

const ALL_DIRS = {
	"N":  Vector2i( 0, -1),
	"S":  Vector2i( 0,  1),
	"E":  Vector2i( 1,  0),
	"W":  Vector2i(-1,  0),
	"NE": Vector2i( 1, -1),
	"NW": Vector2i(-1, -1),
	"SE": Vector2i( 1,  1),
	"SW": Vector2i(-1,  1),
}

func get_neighbors(coords: Vector2i, diagonal: bool = false) -> Dictionary[String, CellData]:
	var dirs = ALL_DIRS if diagonal else CARDINAL_DIRS
	var result: Dictionary[String, CellData] = {}
	for key in dirs:
		var neighbor_coords = coords + dirs[key]
		result[key] = get_cell(neighbor_coords)
	return result
	
func get_neighbors_of_type(coords: Vector2i, terrain: CellData.TerrainType, diagonal: bool = false) -> Array[Vector2i]:
	var dirs = ALL_DIRS if diagonal else CARDINAL_DIRS
	var result: Array[Vector2i] = []
	for key in dirs:
		var neighbor_coords = coords + dirs[key]
		var cell = get_cell(neighbor_coords)
		if cell and cell.terrain == terrain:
			result.append(neighbor_coords)
	return result
	

func _idx(coords: Vector2i) -> int:
	return coords.y * width + coords.x
	
func _in_bounds(coords: Vector2i) -> bool:
	return coords.x >= 0 and coords.x < width and coords.y >= 0 and coords.y < height

# -----------------------------------------
# ------------ helpers --------------------
# -----------------------------------------

# Converts a tile coordinate to the center pixel position of that tile.
func tile_to_world(coords: Vector2i) -> Vector2:
	return Vector2(coords * tile_size) + Vector2(tile_size * 0.5, tile_size * 0.5)

# Converts a pixel world position to the tile coordinate it falls in.
func world_to_tile(world_pos: Vector2) -> Vector2i:
	return Vector2i(world_pos / tile_size)
	
func get_coords_in_radius(center: Vector2i, radius: int) -> Array[Vector2i]:
	if radius == 0:
		return [center]
	var result: Array[Vector2i] = []
	var x := radius
	var y := 0
	var d := 1 - radius
	while x >= y:
		result.append_array([
			Vector2i(center.x + x, center.y + y),
			Vector2i(center.x - x, center.y + y),
			Vector2i(center.x + x, center.y - y),
			Vector2i(center.x - x, center.y - y),
			Vector2i(center.x + y, center.y + x),
			Vector2i(center.x - y, center.y + x),
			Vector2i(center.x + y, center.y - x),
			Vector2i(center.x - y, center.y - x),
		])
		y += 1
		if d <= 0:
			d += 2 * y + 1
		else:
			x -= 1
			d += 2 * (y - x) + 1
	return result
	
# returns nearest tile coords matching the given terrain type
# searches outward in rings from 'origin'
# returns Vector2i(-1, -1) if none found within max_radius
func get_safe_coords(origin: Vector2i, terrain: CellData.TerrainType, max_radius: int = 64) -> Vector2i:
	for radius in range(0, max_radius):
		for coords in get_coords_in_radius(origin, radius):
			var cell: CellData = get_cell(coords)
			if cell and cell.terrain == terrain:
				return coords
	return Vector2i(-1, -1)
	
func get_safe_world_pos(origin: Vector2, terrain: CellData.TerrainType, max_radius: int = 64) -> Vector2:
	var coords: Vector2i = get_safe_coords(world_to_tile(origin), terrain, max_radius)
	if coords == Vector2i(-1, -1):
		return Vector2.INF
	return tile_to_world(coords)

func set_rectangle(position: Vector2i, size: Vector2i, cell: CellData) -> void:
	var rectangle: Rect2i = Rect2i(position, size)
	for y in range(rectangle.position.y, rectangle.position.y + rectangle.size.y):
		for x in range(rectangle.position.x, rectangle.position.x + rectangle.size.x):
			WorldGrid.set_cell(Vector2i(x, y), cell)

func set_circle(center: Vector2i, radius: int, cell: CellData, filled: bool = true) -> void:
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			var coords = Vector2i(x, y)
			if not _in_bounds(coords):
				continue
			var dist = Vector2(coords - center).length()
			if filled and dist <= radius:
				
				set_cell(coords, cell)
			elif not filled and dist <= radius and dist > radius - 1.0:
				set_cell(coords, cell)

# ------------------------------------
# util visibility
# -------------------------------------

const COMPONENT_COUNT_LIMIT: int = 500

func _set_invisible(coords: Vector2i, cell: CellData) -> void:
	# Get all 8 neighbors (including diagonals)
	var neighbors: Dictionary = get_neighbors(coords, true)
	
	# If any neighbor is out-of-bounds, the cell cannot be fully surrounded → visible
	# If any neighbor is a visible non‑wall, the cell cannot be hidden
	for neighbor in neighbors.values():
		if neighbor == null:                # out of bounds
			if cell.invisible:
				cell.invisible = false
				cell_changed.emit(coords)
			return
		if neighbor.terrain != CellData.TerrainType.WALL and not neighbor.invisible:
			if cell.invisible:
				cell.invisible = false
				cell_changed.emit(coords)
			return
	
	# All existing neighbors are either walls or invisible → make this cell invisible
	if not cell.invisible:
		cell.invisible = true
		cell_changed.emit(coords)
		
func _has_revealed_ground_neighbor(coords: Vector2i) -> bool:
	# Returns true if at least one 8-connected neighbor is revealed GROUND
	for n_coords in get_neighbors_of_type(coords, CellData.TerrainType.GROUND, true):
		var n_cell = get_cell(n_coords)
		if not n_cell.invisible:
			return true
	return false		
	
func _count_ground_component(start: Vector2i, visited: Dictionary, out_component: Array[Vector2i]) -> int:
	# Counts (and optionally collects) a connected GROUND component.
	# Stops early once COMPONENT_COUNT_LIMIT is exceeded so we never count the whole map.
	var queue: Array[Vector2i] = [start]
	visited[start] = true
	var count: int = 0
	
	while not queue.is_empty():
		var coords: Vector2i = queue.pop_front()
		var cell: CellData = get_cell(coords)
		if cell == null or cell.terrain != CellData.TerrainType.GROUND:
			continue
		
		count += 1
		if count <= COMPONENT_COUNT_LIMIT:
			out_component.append(coords)
		
		if count > COMPONENT_COUNT_LIMIT:
			out_component.clear()  # we won't hide this component anyway
			return COMPONENT_COUNT_LIMIT + 1  # flag as "large"
		
		# Enqueue all 8-connected ground neighbors
		for n_coords in get_neighbors_of_type(coords, CellData.TerrainType.GROUND, true):
			if not visited.has(n_coords):
				visited[n_coords] = true
				queue.append(n_coords)
	
	return count
	
func _check_and_hide_smaller_component(changed_coords: Vector2i) -> void:
	# Called whenever a GROUND cell becomes non-GROUND.
	# Finds every connected ground component that touched this cell and hides the small ones.
	var adjacent_grounds: Array[Vector2i] = get_neighbors_of_type(changed_coords, CellData.TerrainType.GROUND, true)
	if adjacent_grounds.is_empty():
		return
	
	var visited: Dictionary[Vector2i, bool] = {}
	var small_grounds: Array[Vector2i] = []
	
	for start in adjacent_grounds:
		if visited.has(start):
			continue
		var component: Array[Vector2i] = []
		var size: int = _count_ground_component(start, visited, component)
		if size <= COMPONENT_COUNT_LIMIT:
			small_grounds.append_array(component)
	
	# Hide every small component (grounds only — walls are handled by resolve_visibility_all)
	for coords in small_grounds:
		var cell: CellData = get_cell(coords)
		if cell and not cell.invisible:
			cell.invisible = true
			cell_changed.emit(coords)
	
	# Re-run full visibility pass so any walls that are now fully enclosed become invisible
	# (border walls touching the large revealed side stay visible)
	resolve_visibility_all()
	
func _handle_terrain_change(coords: Vector2i, old_terrain: CellData.TerrainType, new_terrain: CellData.TerrainType) -> void:
	# Central place for the two special cases you described
	if new_terrain == CellData.TerrainType.GROUND and old_terrain != CellData.TerrainType.GROUND:
		if _has_revealed_ground_neighbor(coords):
			_reveal_connected_area(coords)
		else:
			# Internal pocket — force hidden even if the caller passed invisible = false
			var cell: CellData = get_cell(coords)
			if not cell.invisible:
				cell.invisible = true
	
	elif old_terrain == CellData.TerrainType.GROUND and new_terrain != CellData.TerrainType.GROUND:
		_check_and_hide_smaller_component(coords)

# Flood-reveals a whole connected ground area + its bordering walls
func _reveal_connected_area(start: Vector2i) -> void:
	if not _in_bounds(start):
		return
	
	var queue: Array[Vector2i] = [start]
	var visited: Dictionary = {}  # Vector2i → bool
	
	while not queue.is_empty():
		var coords: Vector2i = queue.pop_front()
		if visited.has(coords):
			continue
		visited[coords] = true
		
		var cell: CellData = get_cell(coords)
		if cell == null or cell.terrain != CellData.TerrainType.GROUND:
			continue
		
		# Reveal this ground tile
		if cell.invisible:
			cell.invisible = false
			cell_changed.emit(coords)
		
		# Reveal all 8 bordering wall tiles
		var neighbors := get_neighbors(coords, true)
		for dir in neighbors:
			var wall_coords: Vector2i = coords + ALL_DIRS[dir]
			var n_cell: CellData = neighbors[dir]
			if n_cell and n_cell.terrain == CellData.TerrainType.WALL and n_cell.invisible:
				n_cell.invisible = false
				cell_changed.emit(wall_coords)
		
		# Enqueue neighboring ground tiles (8-connected)
		for dir in neighbors:
			var n_coords: Vector2i = coords + ALL_DIRS[dir]
			var n_cell: CellData = neighbors[dir]
			if n_cell and n_cell.terrain == CellData.TerrainType.GROUND and not visited.has(n_coords):
				queue.append(n_coords)

func resolve_visibility_all() -> void:
	for y in height:
		for x in width:
			var coords: Vector2i = Vector2i(x, y)
			var cell: CellData = get_cell(coords)
			if cell:
				_set_invisible(coords, cell)


