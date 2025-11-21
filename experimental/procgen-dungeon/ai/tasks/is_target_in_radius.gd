@tool
extends BTCondition

@export var radius: float = 5.0

func _generate_name() -> String:
	return "Check the target entity is within radius [%s]" % [
		radius,
	]

func _tick(_delta: float) -> Status:
	var target_body: Node2D
	if blackboard.has_var("target_body") and is_instance_valid(blackboard.get_var("target_body")):
		target_body = blackboard.get_var("target_body")
	if target_body:
		var distance_between: float = agent.global_position.distance_squared_to(target_body.global_position)
		if distance_between <= radius:
			return SUCCESS
	return FAILURE
