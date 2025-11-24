@tool
extends BTAction

@export_enum("Creature", "Fruit", "FruitPlant") var target_class: String = "Creature"

var nav_agent: NavigationAgent2D

func _generate_name() -> String:
	return "Set target_entity to nearest [%s] in sight area" % target_class

func _enter() -> void:
	nav_agent = agent.get_node("NavigationAgent2D")

func _tick(_delta: float) -> Status:
	var nearest_body: Node2D = null
	var closest_distance := 9999999.0

	for body in agent.nearby_bodies:
		if not is_instance_valid(body):
			continue
			
		# ← THIS is the fixed part: use `is` + match instead of is_class()
		var is_correct_type := false
		match target_class:
			"Creature":
				is_correct_type = body is Creature
			"Fruit":
				is_correct_type = body is Fruit
			"FruitPlant":
				is_correct_type = body is FruitPlant
			_:
				is_correct_type = false

		if not is_correct_type:
			continue

		var dist: float = agent.global_position.distance_to(body.global_position)
		if dist < closest_distance:
			closest_distance = dist
			nearest_body = body

	if nearest_body:
		blackboard.set_var("target_entity", nearest_body)
		return SUCCESS
	
	return FAILURE
