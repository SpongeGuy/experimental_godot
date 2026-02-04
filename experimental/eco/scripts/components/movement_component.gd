extends Node
class_name MovementComponent

@export var input_component: InputComponent

var intended_move_direction: Vector2 = Vector2.ZERO
@export var movement_speed: float = 100.0	

	
var effect_velocity: Vector2 = Vector2.ZERO
var effect_velocity_decay_factor: float = 0.5
var move_velocity: Vector2 = Vector2.ZERO
var total_velocity: Vector2 = Vector2.ZERO
var movement_modifier: float = 1.0

func _process(delta: float) -> void:
	intended_move_direction = input_component.get_input_vector()
	
func _physics_process(delta: float) -> void:
	update_move_velocity(delta)
	update_total_velocity(delta)
		
func update_move_velocity(delta: float) -> void:
	movement_modifier = max(movement_modifier, 0.0)
	move_velocity = intended_move_direction * movement_speed * movement_modifier
	
	
	#facing_direction = intended_move_direction.normalized() # THIS MIGHT BE CHANGED LATER
	
	move(delta)
	movement_modifier = 1.0

func update_total_velocity(delta: float) -> void:
	effect_velocity = lerp(effect_velocity, Vector2.ZERO, effect_velocity_decay_factor * delta)
	total_velocity = lerp(total_velocity, effect_velocity + move_velocity, 0.25)

## Applies the current velocity with sliding on collisions using move_and_collide().
func move(delta: float) -> void:
	# can only be used with RigidBody2D
	
	var motion = total_velocity * delta
	var max_slides = 4  # Safety limit to prevent infinite loops in complex geometry
	var slides = 0
	
	while motion != Vector2.ZERO and slides < max_slides:
		var collision = input_component.master_origin.move_and_collide(motion)
		if collision == null:
			break  # No collision, full motion applied
		
		# Slide the remaining motion along the wall
		motion = collision.get_remainder().slide(collision.get_normal())
		slides += 1
