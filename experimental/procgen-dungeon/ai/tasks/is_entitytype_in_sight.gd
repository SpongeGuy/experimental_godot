@tool
extends BTCondition

@export_enum("Creature", "Fruit", "FruitPlant") var target_class: String

func _generate_name() -> String:
	return "Check if [%s] is in sight area" % [
		target_class,
	]

func _tick(_delta: float) -> Status:
	for body in agent.nearby_bodies:
		if body.is_class(target_class):
			return SUCCESS
	return FAILURE
