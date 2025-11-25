@tool

extends BTAction

@export var damage: int

func _generate_name() -> String:
	return "Take %s damage" % [
		damage,
	]

func _tick(_delta: float) -> Status:
	if damage and agent is Creature:
		EventBus.try_change_creature_health.emit(agent, -damage, null)
	return SUCCESS
