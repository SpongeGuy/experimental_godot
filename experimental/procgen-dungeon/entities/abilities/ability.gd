@tool
extends Resource
class_name Ability

enum Type {ACTIVE, PASSIVE, MOVEMENT}

var ability_type: Type

@export var cooldown: float = 0.0
var _remaining_cooldown: float = 0.0

func try_activate(master: Entity, direction: Vector2) -> bool:
	if _remaining_cooldown > 0.0:
		return false
	
	if activate(master, direction) and cooldown > 0.0:
		_remaining_cooldown = cooldown
	return true

# return false if activation fails in some way
func activate(master: Entity, direction: Vector2) -> bool:
	return false

func update_cooldown(delta: float) -> void:
	if _remaining_cooldown > 0.0:
		_remaining_cooldown = max(_remaining_cooldown - delta, 0.0)
