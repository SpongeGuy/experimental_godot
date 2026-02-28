extends MovementComponent
class_name SimpleMovementComponent


func movement_function(delta: float, body: CharacterBody2D) -> void:
	velocity = desired_direction * max_speed
	body.velocity = velocity
