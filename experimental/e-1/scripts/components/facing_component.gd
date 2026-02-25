extends Node
class_name FacingComponent

@export var rotator: Rotator

@export var facing_direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if rotator:
		rotator.intended_rotation = facing_direction.angle()
