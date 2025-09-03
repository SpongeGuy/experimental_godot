extends Area2D

@export var velocity: Vector2 = Vector2(0,0)

func _physics_process(delta: float) -> void:
	position += velocity * delta
