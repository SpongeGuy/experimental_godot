@tool
extends BTAction

@export var speed_var := &"speed"

@export var tolerance := 50.0

var nav_agent: NavigationAgent2D

func _generate_name() -> String:
	return "Move and pathfind to: %s" % [
		nav_agent.target_position
	]
	
func _enter() -> void:
	nav_agent = agent.get_node("NavigationAgent2D")
	blackboard.set_var(speed_var, agent.creature_stats.movement_speed)

func _tick(delta: float) -> Status:
	var target_pos = nav_agent.get_next_path_position()
	if nav_agent.get_final_position().distance_to(agent.global_position) < tolerance:
		return SUCCESS
	
	var speed: float = blackboard.get_var(speed_var, 200.0)
	var dist: float = absf(target_pos.x - agent.global_position.x)
	var dir: Vector2 = agent.global_position.direction_to(target_pos)
	
	var desired_velocity: Vector2 = dir.normalized() * speed

	agent.move(desired_velocity)
	return RUNNING
