extends Camera2D

@export var target: Node2D
@export var camera_smoothing_factor: float = 10

func _process(delta: float) -> void:
	if target:
		global_position = lerp(global_position, target.global_position, delta * camera_smoothing_factor)
	else:
		global_position = lerp(global_position, Vector2.ZERO, delta * camera_smoothing_factor)
