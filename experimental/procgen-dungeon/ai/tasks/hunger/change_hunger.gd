@tool
extends BTAction
@export var amount: float = 0.0

func _generate_name() -> String:
	return "Change hunger by %s" % [
		amount,
	]

func _tick(_delta: float) -> Status:
	
	EventBus.try_change_creature_hunger.emit(agent, amount)
	return FAILURE
