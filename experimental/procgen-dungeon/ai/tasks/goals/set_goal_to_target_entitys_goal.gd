@tool
extends BTAction

@export_enum("short", "long") var self_goal_type: String
@export_enum("short", "long") var target_goal_type: String

func _generate_name() -> String:
	return "Set [%s] term goal to target_entity's [%s] term goal" % [
		self_goal_type,
		target_goal_type,
	]


func _tick(_delta: float) -> Status:
	assert(self_goal_type)
	assert(target_goal_type)
	var target_entity: Entity = blackboard.get_var("target_entity")
	if not target_entity.get("goals"):
		return FAILURE
	agent.goals[target_goal_type] = target_entity.goals[target_goal_type]
	return SUCCESS
