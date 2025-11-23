@tool
extends BTAction

func _generate_name() -> String:
	return "Eat target fruit"

func _tick(_delta: float) -> Status:
	var target_body: Node2D
	if blackboard.has_var("target_body") and is_instance_valid(blackboard.get_var("target_body")):
		target_body = blackboard.get_var("target_body")
	if target_body is Fruit:
		target_body.eat(agent)
		blackboard.unbind_var("target_body")
		return SUCCESS
	return FAILURE
