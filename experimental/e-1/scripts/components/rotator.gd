extends Node2D
class_name Rotator

var intended_rotation: float = 0.0
@export var weight: float = 1.0

func _physics_process(delta: float) -> void:

	rotation = lerp_angle(rotation, intended_rotation, delta * 5)
