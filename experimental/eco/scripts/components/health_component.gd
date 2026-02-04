class_name HealthComponent
extends Node

signal healed(amount: float)
signal harmed(amount: float)
signal died

@export var health: float = 5
@export var max_health: float = 5
@export var invincible: bool = false
@export var invincibility_timer: float = 0.0 # STOPWATCH STYLE
@export var invincibility_timer_length: float = 2.0

func update_invincibility(delta: float) -> void:
	if invincibility_timer > 0:
		invincible = true
		invincibility_timer -= delta
	else:
		invincible = false

func take_damage(amount: float) -> void:
	if invincible:
		return
	health -= amount
	harmed.emit(amount)
	invincibility_timer = invincibility_timer_length
	if health <= 0.0:
		die()
	
func heal(amount: float) -> void:
	health += amount
	if health > max_health:
		health = max_health
	healed.emit(amount)
	
func die() -> void:
	died.emit()
