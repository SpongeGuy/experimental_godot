extends Resource
class_name Ability

enum Type {ACTIVE, PASSIVE, MOVEMENT}

var ability_type: Type

@export var cooldown: float = 0.0
var _remaining_cooldown: float = 0.0

func try_activate(master: Entity) -> bool:
	if _remaining_cooldown > 0.0:
		return false
	
	if activate(master) and cooldown > 0.0:
		_remaining_cooldown = cooldown
	return true

func activate(master: Entity) -> bool:
	return false

func update_cooldown(delta: float) -> void:
	if _remaining_cooldown > 0.0:
		_remaining_cooldown = max(_remaining_cooldown - delta, 0.0)
