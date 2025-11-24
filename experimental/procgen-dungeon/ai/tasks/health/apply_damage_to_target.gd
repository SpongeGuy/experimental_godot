@tool

extends BTAction

@export var damage: int

func _generate_name() -> String:
	return "Apply %s damage to target_entity" % [
		damage,
	]

func _tick(_delta: float) -> Status:
	var target_entity: Node2D
	if blackboard.has_var("target_entity") and is_instance_valid(blackboard.get_var("target_entity")):
		target_entity = blackboard.get_var("target_entity")
	if damage and agent is Creature and target_entity is Creature:
		EventBus.try_change_creature_health.emit(target_entity, -damage, agent)
		return SUCCESS
	return FAILURE
