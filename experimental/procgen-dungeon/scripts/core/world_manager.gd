extends Node

@export var tilemap_layer: TileMapLayer

var chunks: Dictionary = {} # key: Vector2i(chunk_pos), value: Array[Array[Cell]]r
const CHUNK_SIZE: int = 8
var global_seed: int = randi()

func get_chunk(chunk_pos: Vector2i) -> Array:
	return chunks[chunk_pos]

func generate_blank_chunk(chunk_pos: Vector2i) -> Array:
	var arr: Array = []
	for y in CHUNK_SIZE:
		var row: Array = []
		for x in CHUNK_SIZE:
			var global_pos: Vector2i = chunk_pos * CHUNK_SIZE + Vector2i(x, y)
			var cell: Cell = Cell.new(global_pos)
			cell.type = Cell.CellType.SOFT_WALL
			cell.destroyed.connect(_on_cell_destroyed)
			row.append(cell)
			_update_tilemap_tile(global_pos, cell)
		arr.append(row)
		
	chunks[chunk_pos] = arr
	return arr
	
func get_cell(global_pos: Vector2i) -> Cell:
	return

func set_cell(global_pos: Vector2i, new_cell: Cell) -> void:
	pass

func _on_cell_destroyed(global_pos: Vector2i, flag: int) -> void:
	var new_cell = Cell.new(global_pos)
	new_cell.type = Cell.CellType.NONE
	
	var chunk_pos := global_pos / CHUNK_SIZE
	var local_pos := global_pos % CHUNK_SIZE
	var chunk : Array = chunks[chunk_pos]
	chunk[local_pos.y][local_pos.x] = new_cell
	
	_update_tilemap_tile(global_pos, new_cell)
	
	# do extra gameplay logic here based on flags
	
func _update_tilemap_tile(global_pos: Vector2i, cell: Cell) -> void:
	var source_id := 0
	var atlas_coords := _tile_coords_for_cell(cell)
	tilemap_layer.set_cell(global_pos, source_id, atlas_coords)
	tilemap_layer.set_cells_terrain_connect([global_pos], source_id, 0)
	

func _tile_coords_for_cell(cell: Cell) -> Vector2i:
	match cell.type:
		Cell.CellType.SOFT_WALL: return Vector2i(0, 0)
		Cell.CellType.GROUND: return Vector2i(1, 0)
	return Vector2i(-1, -1) # empty
