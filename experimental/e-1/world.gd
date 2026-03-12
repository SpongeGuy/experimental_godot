extends Node2D

@export var world_generator: WorldGenerator

func _ready() -> void:
	initialize_game()
		
func initialize_game() -> void:
	WorldGrid.init_grid(64, 64)
	world_generator.generate()
