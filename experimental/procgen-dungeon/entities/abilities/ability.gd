extends Resource
class_name Ability

enum Type {ACTIVE, PASSIVE, MOVEMENT}

var ability_type: Type

func activate(master: Entity) -> void:
	pass
