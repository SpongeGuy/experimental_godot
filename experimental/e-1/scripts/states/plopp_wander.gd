extends State
class_name PloppWanderState

@export var movement: MovementComponent
@export var wall_avoidance: WallAvoidance
@export var navigation_agent: NavigationAgent2D
@export var animator: SpriteAnimator
@export_group("States")
@export var idle_state: State
@export var plop_state: State


@export_group("Variables")
@export var wander_timer_length: float = 5.0
var wander_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO
@export var wander_radius: float = 250.0


signal picked_new_path(target_position: Vector2)
signal interrupted()

func enter() -> void:
	_pick_new_pathfinding_location(owner.position)
		
	if navigation_agent:
		navigation_agent.navigation_finished.connect(_on_navigation_finished)
		
	interrupted.connect(_decide_if_idle)
	
	if animator:
		animator.load_animation("walk")
		
func update(delta: float) -> void:
	handle_movement(delta)

func handle_movement(delta: float) -> void:
	var old_wander_direction: Vector2 = wander_direction
	wander_timer -= delta
	if wander_timer <= 0:
		interrupted.emit()
		_pick_new_pathfinding_location(owner.position)
		
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	wander_direction = (next_path_position - owner.global_position).normalized()
	var steering = wander_direction
	
	
	if wall_avoidance:
		var avoidance = wall_avoidance.get_avoidance_vector(owner.global_position)
		steering += avoidance
		
		
	movement.set_desired_direction(steering)
	
	
func physics_update(delta: float) -> void:
	movement.physics_update(delta, owner)
	
	if animator:
		animator.update_animation(delta, movement.velocity.length() * 0.2)
		
	

func exit() -> void:
		
	if navigation_agent:
		navigation_agent.navigation_finished.disconnect(_on_navigation_finished)
		
	interrupted.disconnect(_decide_if_idle)
		
func _pick_new_pathfinding_location(origin: Vector2) -> void:
	var angle: float = randf() * TAU
	var distance = randf() * wander_radius
	var target_position: Vector2 = origin + Vector2(cos(angle), sin(angle)) * distance
	navigation_agent.set_target_position(target_position)
	wander_timer = wander_timer_length
	picked_new_path.emit(target_position)
	
func _on_navigation_finished() -> void:
	interrupted.emit()
	_pick_new_pathfinding_location(owner.position)


func _decide_if_idle() -> void:
	var chance: float = 0.3
	if randf() < 0.3:
		state_machine.switch(idle_state)


