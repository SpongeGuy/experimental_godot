@tool
extends BTAction

@export var tolerance := 5.0
@export var avoidance_strength: float = 0.1

var nav_agent: NavigationAgent2D
var safe_velocity: Vector2 = Vector2.ZERO   
var velocity_ready: bool = false

func _generate_name() -> String:
	return "Pathfind and move with tolerance %s and avoidance strength %s" % [
		tolerance,
		avoidance_strength
	]

func _enter() -> void:
	nav_agent = agent.get("nav_agent")
	if not nav_agent.velocity_computed.is_connected(_on_velocity_computed):
		nav_agent.velocity_computed.connect(_on_velocity_computed)

func _tick(_delta: float) -> Status:
	if agent.accept_player_input:
		var player_intended_velocity: Vector2 = Input.get_vector("move_west", "move_east", "move_north", "move_south").normalized() * agent.stats.base_speed
		agent.nav_velocity = player_intended_velocity
		agent.move(_delta)
	else:
		var target_pos = nav_agent.get_next_path_position()
		if nav_agent.get_final_position().distance_to(agent.global_position) < tolerance:
			return SUCCESS
			
		var dir: Vector2 = agent.global_position.direction_to(target_pos)
		
		var desired_velocity: Vector2 = dir.normalized() * agent.stats.base_speed
		if agent.use_rvo_avoidance:
			nav_agent.velocity = desired_velocity
			velocity_ready = false
			
			await agent.get_tree().process_frame
			
			var blended_velocity = desired_velocity.lerp(safe_velocity, avoidance_strength)
			agent.nav_velocity = blended_velocity
		else:
			nav_agent.velocity = desired_velocity
			agent.nav_velocity = desired_velocity
		agent.move(_delta)
		
	return RUNNING
	
func _on_velocity_computed(received_safe_velocity: Vector2) -> void:
	safe_velocity = received_safe_velocity
	velocity_ready = true
