extends Node
class_name MovementComponent

@export var max_speed: float = 100.0
@export var acceleration: float = 500.0
@export var friction: float = 800.0 # how fast it stopps
@export var rotation_speed: float = 10.0 # for smooth turning


var velocity: Vector2 = Vector2.ZERO
var desired_direction: Vector2 = Vector2.ZERO

signal started_moving(direction: Vector2)
signal stopped_moving()
signal changed_direction(old_direction: Vector2, new_direction: Vector2)


var moving: bool = false

func set_desired_direction(dir: Vector2) -> void:
	if dir.length() > 0:
		desired_direction = dir.normalized()
	else:
		desired_direction = Vector2.ZERO
	
func physics_update(delta: float, body: CharacterBody2D) -> void:
	var old_velocity = velocity
	if desired_direction.length() > 0:
		var target_velocity = desired_direction * max_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	if abs(velocity.x) < 0.05 or abs(velocity.y) < 0.05:
		if moving:
			stopped_moving.emit()
		moving = false
	else:
		if not moving:
			started_moving.emit(velocity.normalized())
		moving = true 
		
	body.velocity = velocity
	body.move_and_slide()
	_check_if_change_direction(old_velocity, velocity)
	
func _check_if_change_direction(old_direction: Vector2, new_direction: Vector2) -> void:
	var x_sign_changed = sign(old_direction.x) != sign(new_direction.x) and old_direction.x != 0 and new_direction.x != 0
	var y_sign_changed = sign(old_direction.y) != sign(new_direction.y) and new_direction.y != 0 and new_direction.y != 0
	
	if x_sign_changed or y_sign_changed:
		changed_direction.emit(old_direction, new_direction)
