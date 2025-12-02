@tool
extends BTAction

@export_enum("short", "long") var goal_type: String

func _generate_name() -> String:
	return "Set [%s] term goal to target_position" % [
		goal_type
	]


func _tick(_delta: float) -> Status:
	assert(goal_type)
	var target_pos: Vector2 = blackboard.get_var("target_position")
	agent.goals[goal_type] = target_pos
	return SUCCESS
