extends Node

var chunks: Dictionary = {} # key: Vector2i(chunk_pos), value: Array[Array[Cell]]
const chunk_size: int = 8
var global_seed: int = randi()

func get_chunk(chunk_pos: Vector2i) -> Array:
	return chunks[chunk_pos]

func _generate_blank_chunk(chunk_pos: Vector2i) -> Array:
	var arr: Array = []
	for y in chunk_size:
		var row: Array = []
		for x in chunk_size:
			var global_pos: Vector2i = chunk_pos * chunk_size + Vector2i(x, y)
			var cell: Cell = Cell.new(global_pos)
			cell.destroyed.connect(_on_cell_destroyed)
			row.append(cell)
		arr.append(row)
	return arr
	
func get_cell(global_pos: Vector2i) -> Cell:
	return

func set_cell(global_pos: Vector2i, new_cell: Cell) -> void:
	pass

func _on_cell_destroyed(global_pos: Vector2i, flag: int) -> void:
	pass

