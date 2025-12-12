@tool
extends BTAction

var target_entity: Entity

func _generate_name() -> String:
	return "Face towards target_entity"
	
func _enter() -> void:
	target_entity = blackboard.get_var("target_entity")

func _tick(_delta: float) -> Status:
	if not is_instance_valid(target_entity):
		return FAILURE
	
	var direction_to_target: Vector2 = (target_entity.global_position - agent.global_position).normalized()
	agent.facing_direction = direction_to_target
	return SUCCESS
