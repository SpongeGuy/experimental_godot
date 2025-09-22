extends Control

func _ready() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	position.x = screen_size.x/2 - screen_size.y/2
