@tool
extends BTAction

@export_enum("short", "long") var goal_type: String

func _generate_name() -> String:
	return "Set [%s] term goal to target_entity's position" % [
		goal_type
	]


func _tick(_delta: float) -> Status:
	assert(goal_type)
	var target_entity: Entity = blackboard.get_var("target_entity")
	agent.goals[goal_type] = target_entity.global_position
	return SUCCESS
