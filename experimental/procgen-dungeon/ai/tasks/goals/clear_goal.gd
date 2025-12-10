@tool
extends BTAction

@export_enum("short", "long") var goal_type: String

func _generate_name() -> String:
	return "Clear [%s] term goal" % [
		goal_type
	]


func _tick(_delta: float) -> Status:
	assert(goal_type)
	agent.goals[goal_type] = Vector2.INF
	return SUCCESS
