extends Node

@export var world_manager: Node
@export var tilemap_layer: TileMapLayer

func _ready() -> void:
	
	world_manager.generate_chunk_at_global(Vector2i(-1, 0))
	world_manager.generate_chunk_at_global(Vector2i(0, 0))
	world_manager.generate_chunk_at_global(Vector2i(1, 0))
	world_manager.generate_chunk_at_global(Vector2i(0, -1))
	world_manager.generate_chunk_at_global(Vector2i(-2, -1))
	world_manager.generate_chunk_at_global(Vector2i(-2, -2))
	
	
	

var debug_keys: Dictionary = {
	KEY_F1: "function1",
}

func _handle_debug_key(keycode: int, action: String) -> void:
	match action:
		"function1":
			var cell_position = Vector2i(4, 4)
			var cell = Cell.new(cell_position)
			cell.type = Cell.CellType.GROUND
			world_manager.set_cell(cell_position, cell)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var keycode = event.keycode
		if debug_keys.has(keycode):
			_handle_debug_key(keycode, debug_keys[keycode])
	
	if event is InputEventMouseButton:
		var local_pos = tilemap_layer.get_local_mouse_position()
		var cell_pos = tilemap_layer.local_to_map(local_pos)
		
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				var cell: Cell = Cell.new(local_pos)
				cell.type = Cell.CellType.SOFT_WALL
				world_manager.set_cell(cell_pos, cell)
