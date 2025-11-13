extends Node

@export var world_manager: Node

func _ready() -> void:
	world_manager.generate_blank_chunk(Vector2i.ZERO)
	world_manager.generate_blank_chunk(Vector2i(-1, 0))
	print(world_manager.chunks)
