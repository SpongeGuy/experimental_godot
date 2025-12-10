@tool
extends BTCondition

@export_enum("short", "long") var goal_type: String

func _generate_name() -> String:
	return "Check if [%s] term goal exists" % [
		goal_type
	]


func _tick(_delta: float) -> Status:
	assert(goal_type)
	if agent.goals[goal_type] == Vector2.INF:
		return FAILURE
	return SUCCESS
