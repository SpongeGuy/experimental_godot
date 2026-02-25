extends State
class_name PathfindToTargetState

@export var movement: MovementComponent
@export var wall_avoidance: WallAvoidance
@export var target_seeker: TargetSeeker
@export var navigation_agent: NavigationAgent2D
@export var exit_state: State
@export var animator: SpriteAnimator

@export var timer_length: float = 5.0
var target: Node2D
var target_position: Vector2 = Vector2.INF
var chase_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO
@export var wander_radius: float = 250.0


signal picked_new_path(target_position: Vector2)
signal target_lost()
signal interrupted()

func enter() -> void:
	target = _get_target()
	if target:
		target_position = target.global_position
	_pick_new_pathfinding_location(owner.position)
	
	if navigation_agent:
		navigation_agent.navigation_finished.connect(_on_navigation_finished)
	
	target_lost.connect(_on_target_lost)
	
	if animator:
		animator.load_animation("walk")
		
func update(delta: float) -> void:
	if not is_instance_valid(target):
		target_lost.emit()
	
	target = _get_target()
	
	if target:
		target_position = target.global_position
	else:
		chase_timer -= delta
	_pick_new_pathfinding_location(owner.position)
	
	var old_wander_direction: Vector2 = wander_direction
	chase_timer = timer_length
	
	
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	wander_direction = (next_path_position - owner.global_position).normalized()
	var steering = wander_direction
	
	if wall_avoidance:
		var avoidance = wall_avoidance.get_avoidance_vector(owner.global_position)
		steering += avoidance
		

	movement.set_desired_direction(steering)
	if chase_timer <= 0.0:
		target_lost.emit()
	
	
func physics_update(delta: float) -> void:
	movement.physics_update(delta, owner)
	
	if animator:
		animator.update_animation(delta, movement.velocity.length() * 0.2)
		
func _on_target_lost() -> void:
	state_machine.switch(exit_state)

func exit() -> void:
	if navigation_agent:
		navigation_agent.navigation_finished.disconnect(_on_navigation_finished)
		
	target_lost.disconnect(_on_target_lost)
		
		
func _pick_new_pathfinding_location(origin: Vector2) -> void:
	navigation_agent.set_target_position(target_position)
	chase_timer = timer_length
	picked_new_path.emit(target_position)
	
func _on_navigation_finished() -> void:
	interrupted.emit()
	_pick_new_pathfinding_location(owner.position)


func _get_target() -> Node2D:
	if target_seeker:
		var target = target_seeker.find_nearest_target(
			owner.global_position,
			movement.velocity.normalized()
		)
	
		return target
	return null
