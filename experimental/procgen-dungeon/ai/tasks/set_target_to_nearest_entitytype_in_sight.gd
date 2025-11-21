@tool
extends BTAction


@export_enum("Creature", "Fruit", "FruitPlant") var target_class: String

var nav_agent: NavigationAgent2D

func _generate_name() -> String:
	return "Set pathfind target to nearest [%s] in sight area" % [
		target_class,
	]

func _enter() -> void:
	nav_agent = agent.get_node("NavigationAgent2D")
	
func _tick(_delta: float) -> Status:
	var target_pos: Vector2
	var max_value = 9999999
	var nearest_body: Node2D
	for body in agent.nearby_bodies:
		if !body.is_class(target_class):
			continue
		var distance: float = agent.global_position.distance_to(body.global_position)
		if max_value > distance:
			max_value = distance
			nearest_body = body
	if nearest_body:
		blackboard.set_var("target_body", nearest_body)
		target_pos = nearest_body.global_position
		nav_agent.target_position = target_pos
		return SUCCESS
	else: 
		return FAILURE
