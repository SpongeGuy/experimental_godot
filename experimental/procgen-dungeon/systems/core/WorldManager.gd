# world manager
class_name WorldManager
extends Node

@export var tilemap_layer: TileMapLayer
@export var world: World

var chunks: Dictionary = {} # key: Vector2i(chunk_pos), value: Array[Array[Cell]]
const CHUNK_SIZE: int = 8
var global_seed: int = randi()

var cell_terrain_type: Dictionary = {
	Cell.CellType.NONE: -1,
	Cell.CellType.SOFT_WALL: 0,
	Cell.CellType.GROUND: 1,
}

func generate_debug_chunk_at_global(chunk_pos: Vector2i) -> void:		
	create_chunk(chunk_pos)
	var chunk = get_chunk(chunk_pos)
	for y in CHUNK_SIZE:
		#var row: Array = []
		for x in CHUNK_SIZE:
			chunk[y][x].type = Cell.CellType.GROUND
			chunk[y][x].health = 3  # Optional: set default health
			chunk[y][x].destroyed.connect(_on_cell_destroyed)
	
	_update_chunk_visuals(chunk_pos)
	
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

func set_cell(cell_pos: Vector2i, new_cell: Cell) -> void:
	print()
	print("cell_pos", cell_pos % CHUNK_SIZE)
	print("chunk_pos", cell_pos_to_chunk(cell_pos))
	var chunk: Array = get_chunk(cell_pos_to_chunk(cell_pos))
	if chunk == []:
		print("No chunk found! Creating one!")
		chunk = create_chunk(cell_pos_to_chunk(cell_pos))
	print(chunk != [])
	var local_pos: Vector2i = cell_pos % CHUNK_SIZE
	
	chunk[local_pos.y][local_pos.x] = new_cell
	_update_cell_tiling(cell_pos)
	#tilemap_layer.set_cells_terrain_connect([cell_pos], 0, 0)

func _on_cell_destroyed(cell_pos: Vector2i, _flag: int) -> void:
	var new_cell = Cell.new(cell_pos)
	new_cell.type = Cell.CellType.NONE
	
	var chunk_pos := cell_pos / CHUNK_SIZE
	var local_pos := cell_pos % CHUNK_SIZE
	var chunk : Array = chunks[chunk_pos]
	chunk[local_pos.y][local_pos.x] = new_cell
	
	_update_tilemap_tile(cell_pos, new_cell)
	
	# do extra gameplay logic here based on flags
	
func _update_tilemap_tile(cell_pos: Vector2i, cell: Cell) -> void:
	var source_id := 0
	var atlas_coords := _tile_coords_for_cell(cell)
	tilemap_layer.set_cell(cell_pos, source_id, atlas_coords)
	#_update_cell_tiling(cell_pos)
	
func _update_cell_tiling(cell_pos: Vector2i) -> void:
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
				tilemap_layer.set_cells_terrain_connect([adj_pos], 0, terrain)
	else:
		if cell_terrain_type.has(cell.type):
			var terrain: int = cell_terrain_type[cell.type]
			tilemap_layer.set_cells_terrain_connect([cell_pos], 0, terrain)
	
func _update_chunk_visuals(chunk_pos: Vector2i) -> void:
	#var cell_positions: Array = []
	for y in CHUNK_SIZE:
		for x in CHUNK_SIZE:
			var cell_pos: Vector2i = chunk_pos * CHUNK_SIZE + Vector2i(x, y)
			_update_cell_tiling(cell_pos)

func _tile_coords_for_cell(cell: Cell) -> Vector2i:
	match cell.type:
		Cell.CellType.SOFT_WALL: return Vector2i(0, 0)
		Cell.CellType.GROUND: return Vector2i(1, 0)
	return Vector2i(-1, -1) # empty
