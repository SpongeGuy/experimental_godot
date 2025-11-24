@tool
extends BTCondition

@export var radius: float = 5.0

func _generate_name() -> String:
	return "Check the target_entity is within radius [%s]" % [
		radius,
	]

func _tick(_delta: float) -> Status:
	var target_entity: Node2D
	if blackboard.has_var("target_entity") and is_instance_valid(blackboard.get_var("target_entity")):
		target_entity = blackboard.get_var("target_entity")
	if target_entity:
		var distance_between: float = agent.global_position.distance_squared_to(target_entity.global_position)
		if distance_between <= radius:
			return SUCCESS
	return FAILURE
