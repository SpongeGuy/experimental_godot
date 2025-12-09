extends Node

@export var world_manager: WorldManager
@export var tilemap_layer: TileMapLayer

@export var debug_camera: Camera2D

var large_chunk: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)
]

func _ready() -> void:
	
	for x in range (-3, 3):
		for y in range(-2, 2):
			world_manager.generate_debug_chunk_at_global(Vector2i(x, y))
	

var debug_keys: Dictionary = {
	KEY_F1: "function1",
}

func _handle_debug_key(_keycode: int, action: String) -> void:
	match action:
		"function1":
			var cell_position = Vector2i(4, 4)
			var cell = Cell.new(cell_position)
			cell.type = Cell.CellType.GROUND
			world_manager.set_cell(cell_position, cell)

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
		
		
	
	if event is InputEventMouseButton:
		var local_pos = tilemap_layer.get_local_mouse_position()
		var cell_pos = tilemap_layer.local_to_map(local_pos)
		
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				var cell: Cell = Cell.new(local_pos)
				cell.type = Cell.CellType.SOFT_WALL
				world_manager.set_cell(cell_pos, cell)
			if event.button_index == MOUSE_BUTTON_RIGHT:
				var cell: Cell = Cell.new(local_pos)
				cell.type = Cell.CellType.GROUND
				world_manager.set_cell(cell_pos, cell)
