@tool

extends BTAction

@export var damage: int

func _generate_name() -> String:
	return "Take %s damage" % [
		damage,
	]

func _tick(_delta: float) -> Status:
	if damage and agent is Creature:
		agent.take_damage(damage)
	return SUCCESS
