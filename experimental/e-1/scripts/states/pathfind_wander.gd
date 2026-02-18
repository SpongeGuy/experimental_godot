extends State
class_name PathfindWanderState

@export var movement: MovementComponent
@export var wall_avoidance: WallAvoidance
@export var target_seeker: TargetSeeker
@export var navigation_agent: NavigationAgent2D
@export var chase_state: State
@export var idle_state: State

@export var timer_length: float = 5.0
var wander_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO
@export var wander_radius: float = 250.0


signal picked_new_path(target_position: Vector2)
signal changed_direction(old_direction: Vector2, new_direction: Vector2)
signal interrupted()

func enter() -> void:
	_pick_new_pathfinding_location(owner.position)
	if target_seeker:
		target_seeker.target_found.connect(_on_target_found)
		
	if navigation_agent:
		navigation_agent.navigation_finished.connect(_on_navigation_finished)
		
	interrupted.connect(_decide_if_idle)
		
func update(delta: float) -> void:
	var old_wander_direction: Vector2 = wander_direction
	wander_timer -= delta
	if wander_timer <= 0:
		interrupted.emit()
		_pick_new_pathfinding_location(owner.position)
		
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	wander_direction = (next_path_position - owner.global_position).normalized()
	var steering = wander_direction
	
	_check_if_change_direction(old_wander_direction, wander_direction)
	
	if wall_avoidance:
		var avoidance = wall_avoidance.get_avoidance_vector(owner.global_position)
		steering += avoidance
		
	if target_seeker:
		var target = target_seeker.find_nearest_target(
			owner.global_position,
			movement.velocity.normalized()
		)
		
	movement.set_desired_direction(steering)
	
func physics_update(delta: float) -> void:
	movement.physics_update(delta, owner)



func exit() -> void:
	if target_seeker:
		target_seeker.target_found.disconnect(_on_target_found)
		
	if navigation_agent:
		navigation_agent.navigation_finished.disconnect(_on_navigation_finished)
		
func _pick_new_pathfinding_location(origin: Vector2) -> void:
	var angle: float = randf() * TAU
	var distance = randf() * wander_radius
	var target_position: Vector2 = origin + Vector2(cos(angle), sin(angle)) * distance
	navigation_agent.set_target_position(target_position)
	wander_timer = timer_length
	picked_new_path.emit(target_position)
	
func _on_navigation_finished() -> void:
	interrupted.emit()
	_pick_new_pathfinding_location(owner.position)

func _on_target_found(target: Node2D) -> void:
	if chase_state:
		state_machine.switch(chase_state)


func _decide_if_idle() -> void:
	var chance: float = 0.3
	if randf() < 0.3:
		state_machine.switch(idle_state)

func _check_if_change_direction(old_direction: Vector2, new_direction: Vector2) -> void:
	var x_sign_changed = sign(old_direction.x) != sign(new_direction.x) and old_direction.x != 0 and new_direction.x != 0
	var y_sign_changed = sign(old_direction.y) != sign(new_direction.y) and new_direction.y != 0 and new_direction.y != 0
	
	if x_sign_changed or y_sign_changed:
		print("YES")
		changed_direction.emit(old_direction, new_direction)
