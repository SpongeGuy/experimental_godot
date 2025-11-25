@tool
extends BTAction

@export var tolerance := 50.0

var nav_agent: NavigationAgent2D

func _generate_name() -> String:
	return "Pathfind and move with tolerance %s" % [
		tolerance
	]

func _enter() -> void:
	nav_agent = agent.get_node("NavigationAgent2D")

func _tick(_delta: float) -> Status:
	var target_pos = nav_agent.get_next_path_position()
	if nav_agent.get_final_position().distance_to(agent.global_position) < tolerance:
		return SUCCESS
		
	var dir: Vector2 = agent.global_position.direction_to(target_pos)
	
	var desired_velocity: Vector2 = dir.normalized() * agent.stats.base_speed
	
	agent.nav_velocity = desired_velocity
	agent.move()
	return RUNNING	
	
	
