extends Node
# AUTOLOAD AS WorldGrid

var width: int = 64
var height: int = 64
var _grid: Array[CellData] = []
var tile_size: int = 16

signal cell_changed(coords: Vector2i)
signal grid_loaded

func init_grid(w: int, h: int) -> void:
	width = w
	height = h
	_grid.clear()
	_grid.resize(w * h)
	for i in _grid.size():
		_grid[i] = CellData.new()
	grid_loaded.emit()
		
func get_cell(coords: Vector2i) -> CellData:
	if not _in_bounds(coords):
		
		return null
	return _grid[_idx(coords)]

func set_cell(coords: Vector2i, data: CellData) -> void:
	if not _in_bounds(coords):
		return
	
	_grid[_idx(coords)] = data
	cell_changed.emit(coords)
	

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

func get_neighbors(coords: Vector2i, diagonal: bool = false) -> Dictionary:
	var dirs = ALL_DIRS if diagonal else CARDINAL_DIRS
	var result = {}
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
				print(coords)
				continue
			var dist = Vector2(coords - center).length()
			if filled and dist <= radius:
				
				set_cell(coords, cell)
			elif not filled and dist <= radius and dist > radius - 1.0:
				set_cell(coords, cell)
