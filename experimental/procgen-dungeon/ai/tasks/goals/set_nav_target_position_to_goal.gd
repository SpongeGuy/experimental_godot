@tool
extends BTAction

@export_enum("short", "long") var goal_type: String

func _generate_name() -> String:
	return "Set navigation target to [%s] term goal" % [
		goal_type
	]


func _tick(_delta: float) -> Status:
	assert(goal_type)
	agent.nav_agent.target_position = agent.goals[goal_type]
	return SUCCESS
