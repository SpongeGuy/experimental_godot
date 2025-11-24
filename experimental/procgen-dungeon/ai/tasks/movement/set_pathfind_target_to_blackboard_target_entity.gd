@tool
extends BTAction

var nav_agent: NavigationAgent2D
var target_entity: Node2D

func _generate_name() -> String:
	return "Set pathfind target position to target_entity"

func _enter() -> void:
	nav_agent = agent.nav_agent
	target_entity = blackboard.get_var("target_entity")

func _tick(delta: float) -> Status:
	if target_entity:
		nav_agent.target_position = target_entity.global_position
		return SUCCESS
	return FAILURE
	
