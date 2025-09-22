extends Node

@onready var world = $GameContainer/GameViewportContainer/GameViewport/World

func _ready() -> void:
	world.add_to_group("world")
