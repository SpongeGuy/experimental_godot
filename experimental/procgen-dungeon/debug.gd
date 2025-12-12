extends Node

@export var tilemap_layer: TileMapLayer

@export var debug_camera: Camera2D

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
			var cell = Cell.new(cell_position)
			cell.type = Cell.CellType.GROUND
			WorldManager.set_cell(cell_position, cell, tilemap_layer)

func _process(delta: float) -> void:
	#_debug_camera(delta)
	pass
		
func _debug_camera(delta: float) -> void:
	var camera_movement: Vector2 = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	if camera_movement.length() >= 0.1 and debug_camera:
		debug_camera.position += camera_movement * delta * 250



func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var keycode = event.keycode
		if debug_keys.has(keycode):
			_handle_debug_key(keycode, debug_keys[keycode])
	if event.is_action_pressed("use") and not PlayerManager.player_instance:
		get_tree().reload_current_scene()
	
	if event is InputEventMouseButton:
		WorldManager.spawn_irregular_blob(tilemap_layer.get_local_mouse_position(), 50, Cell.CellType.SOFT_WALL, tilemap_layer)
		#var local_pos = tilemap_layer.get_local_mouse_position()
		#var cell_pos = tilemap_layer.local_to_map(local_pos)
		#
		#if event.pressed:
			#if event.button_index == MOUSE_BUTTON_LEFT:
				#var cell: Cell = Cell.new(local_pos)
				#cell.type = Cell.CellType.SOFT_WALL
				#WorldManager.set_cell(cell_pos, cell, tilemap_layer)
			#if event.button_index == MOUSE_BUTTON_RIGHT:
				#var cell: Cell = Cell.new(local_pos)
				#cell.type = Cell.CellType.GROUND
				#WorldManager.set_cell(cell_pos, cell, tilemap_layer)
