extends Control

@export var show: bool = false
@export var vbox: VBoxContainer
@export var l1: Label
@export var l2: Label
@export var camera: CameraController

func _process(delta: float) -> void:
	if not show:
		visible = false
		return
	
	var coords: Vector2
	if camera.camera:
		coords = get_viewport().get_mouse_position()
		coords += camera.camera.position - Vector2(320, 180)
		vbox.position = get_window().get_mouse_position()
		l1.text = str(WorldGrid.world_to_tile(coords))
		var cell: CellData = WorldGrid.get_cell(WorldGrid.world_to_tile(coords))
		if cell:
			var string = ""
			for entry in AnthuriumBrain.active_anthurium_parts:
				string += str(entry, ": ", AnthuriumBrain.active_anthurium_parts[entry], "\n")
			l2.text = str(string)
