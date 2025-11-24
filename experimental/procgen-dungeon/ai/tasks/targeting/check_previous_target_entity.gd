@tool
extends BTAction

var target_entity
var previous_entity

func _generate_name() -> String:
	return "Check if target_entity is previous_target, then set previous to target"
	
func _enter() -> void:
	target_entity = blackboard.get_var("target_entity")
	previous_entity = blackboard.get_var("previous_entity")

func _tick(_delta: float) -> Status:
	if target_entity and target_entity == previous_entity:
		return SUCCESS
	if not previous_entity:
		previous_entity = target_entity
		return SUCCESS
	return FAILURE
