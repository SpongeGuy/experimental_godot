class_name AbilityComponent
extends Node

@export_group("Casting")
@export var use_cast_timer: float = 0.0
@export var use_cast_timer_limit: float = 1.0

@export var cast_cooldown_timer: float = 0.0
@export var cast_cooldown_timer_limit: float = 0.0

@export var use_effect: Resource


func try_use(delta: float, user: Creature) -> bool:
	use_cast_timer += delta
	if use_cast_timer >= use_cast_timer_limit:
		use(user)
		use_cast_timer = 0.0
		return true
	return false
		
func use(user: Creature) -> void:
	pass


