@tool
extends BTCondition

@export_enum("Creature", "Fruit", "FruitPlant") var target_class: String = "Creature"

func _generate_name() -> String:
	return "Check if [%s] is in sight area" % target_class

func _tick(_delta: float) -> Status:
	for body in agent.nearby_bodies:
		if not is_instance_valid(body):
			continue
			
		match target_class:
			"Creature":
				if body is Creature:
					return SUCCESS
			"Fruit":
				if body is Fruit:
					return SUCCESS
			"FruitPlant":
				if body is FruitPlant:          # ← this works because of class_name
					return SUCCESS
	return FAILURE
