@tool
extends BTAction

@export var tolerance := 50.0

var nav_agent: NavigationAgent2D

func _generate_name() -> String:
	return "Pathfind and move with tolerance %s" % [
		tolerance
	]

func _enter() -> void:
	nav_agent = agent.get("nav_agent")

func _tick(_delta: float) -> Status:
	if agent.accept_player_input:
		var player_intended_velocity: Vector2 = Input.get_vector("move_west", "move_east", "move_north", "move_south").normalized() * agent.stats.base_speed
		agent.nav_velocity = player_intended_velocity
		agent.move()
	else:
		var target_pos = nav_agent.get_next_path_position()
		if nav_agent.get_final_position().distance_to(agent.global_position) < tolerance:
			return SUCCESS
			
		var dir: Vector2 = agent.global_position.direction_to(target_pos)
		
		var desired_velocity: Vector2 = dir.normalized() * agent.stats.base_speed
		
		agent.nav_velocity = desired_velocity
		agent.move()
	return RUNNING
	
	
