extends Node
class_name MovementComponent

var intended_move_direction: Vector2 = Vector2.ZERO
@export var movement_speed: float = 100.0	
@export var navigation_agent: NavigationAgent2D

@export var master_origin: Node2D
var effect_velocity: Vector2 = Vector2.ZERO
var effect_velocity_decay_factor: float = 0.5
var move_velocity: Vector2 = Vector2.ZERO
var total_velocity: Vector2 = Vector2.ZERO
var movement_modifier: float = 1.0

signal moving(intended_velocity: Vector2, total_velocity: Vector2)

signal goal_complete(intent: Intent)

var is_player: bool = true
var switch: bool = false

func _physics_process(delta: float) -> void:
	if is_player:
		handle_movement(delta)

func register_action_handlers(executor: IntentExecutor):
	executor.register_action("move_to_location", _handle_move_to_location)

func _handle_move_to_location(delta: float, intent: Intent) -> void:
	is_player = false
	# move to a location (moving is done either using pathfinding or automatically every frame using move_direction)
	# once the location has been reached, signal goal_complete
	
	if navigation_agent:
		if not switch:
			set_pathfinding_movement_target(intent.target_position)
			switch = true
		do_pathfinding(delta)
		handle_movement(delta)
		if navigation_agent.is_navigation_finished():
			goal_complete.emit(intent)
			switch = false
	else:
		var tolerance: float = intent.parameters.get("tolerance", 25.0)
		var direction: Vector2 = (intent.target_position - master_origin.position).normalized()
		set_intended_move_direction(direction)
		handle_movement(delta)
		if master_origin.position.distance_squared_to(intent.target_position) < tolerance:
			goal_complete.emit(intent)
			switch = false
	
	
func set_intended_move_direction(direction: Vector2) -> void:
	intended_move_direction = direction
	
func set_pathfinding_movement_target(movement_target: Vector2) -> void:
	navigation_agent.set_target_position(movement_target)
	
	
func do_pathfinding(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		return
		
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = master_origin.global_position.direction_to(next_path_position)
	intended_move_direction = new_velocity	


	
func handle_movement(delta: float) -> void:
	update_move_velocity(delta)
	update_total_velocity(delta)
	move(delta)
	movement_modifier = 1.0
		
func update_move_velocity(delta: float) -> void:
	movement_modifier = max(movement_modifier, 0.0)
	move_velocity = intended_move_direction * movement_speed * movement_modifier
	
	

func update_total_velocity(delta: float) -> void:
	effect_velocity = lerp(effect_velocity, Vector2.ZERO, effect_velocity_decay_factor * delta)
	total_velocity = lerp(total_velocity, effect_velocity + move_velocity, 0.25)

## Applies the current velocity with sliding on collisions using move_and_collide().
func move(delta: float) -> void:
	if master_origin is not RigidBody2D:
		return
	# can only be used with RigidBody2D
	
	var motion = total_velocity * delta
	var max_slides = 4  # Safety limit to prevent infinite loops in complex geometry
	var slides = 0
	
	while motion != Vector2.ZERO and slides < max_slides:
		var collision = master_origin.move_and_collide(motion)
		if collision == null:
			break  # No collision, full motion applied
		
		# Slide the remaining motion along the wall
		motion = collision.get_remainder().slide(collision.get_normal())
		slides += 1
		
	moving.emit(move_velocity, total_velocity)
