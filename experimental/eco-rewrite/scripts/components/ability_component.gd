class_name AbilityComponent
extends Node

var use_cast_timer: float = 0.0

var cast_cooldown_timer: float = 0.0
@export var master_origin: Node2D
@export var use_effect: Ability
@export var consumable_component: ConsumableComponent
@export var cast_time: float = 1.0
@export var cooldown_time: float = 0.0


var deactivated: bool = false

signal used

func activate() -> void:
	deactivated = false
	
func deactivate() -> void:
	deactivated = true

func reset_cast_timer() -> void:
	use_cast_timer = 0.0
	
func reset_cooldown_timer() -> void:
	cast_cooldown_timer = 0.0
	
func _process(delta: float) -> void:
	if cast_cooldown_timer > 0.0:
		cast_cooldown_timer -= delta

func try_use(delta: float, user: Creature) -> bool:
	if deactivated:
		return false
	if cast_cooldown_timer <= 0.0:
		use_cast_timer += delta
	if use_cast_timer >= cast_time:
		use(user)
		use_cast_timer = 0.0
		used.emit()
		cast_cooldown_timer = cooldown_time
		return true
	return false
		
func use(user: Creature) -> void:
	use_effect.execute(user, master_origin)


