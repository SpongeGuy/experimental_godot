extends Node

@export var tilemap_layer: TileMapLayer

var large_chunk: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)
]


	

var debug_keys: Dictionary = {
	KEY_F1: "function1",
}



func _handle_debug_key(_keycode: int, action: String) -> void:
	match action:
		"function1":
			var cell_position = Vector2i(4, 4)
			var cell = Cell.new(cell_position, Cell.CellType.GROUND)
			WorldManager.set_cell(cell_position, cell, tilemap_layer)





func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var keycode = event.keycode
		if debug_keys.has(keycode):
			_handle_debug_key(keycode, debug_keys[keycode])
	if event.is_action_pressed("use") and not PlayerManager.player_instance:
		get_tree().reload_current_scene()

