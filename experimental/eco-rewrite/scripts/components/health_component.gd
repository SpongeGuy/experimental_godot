class_name HealthComponent
extends Node

signal healed(amount: float, source: Node2D)
signal harmed(amount: float, source: Node2D)
signal died

@export var health: float = 5
@export var max_health: float = 5
@export var invincible: bool = false
var invincibility_timer: float = 0.0 # STOPWATCH STYLE
@export var invincibility_time: float = 2.0


func _process(delta: float) -> void:
	update_invincibility(delta)

func update_invincibility(delta: float) -> void:
	if invincibility_timer > 0:
		invincible = true
		invincibility_timer -= delta
	else:
		invincible = false
		

func take_damage(amount: float, attacker: Node2D) -> void:
	if invincible:
		return
	health -= amount
	harmed.emit(amount, attacker)
	invincibility_timer = invincibility_time
	if health <= 0.0:
		die()
	
func heal(amount: float) -> void:
	health += amount
	if health > max_health:
		health = max_health
	healed.emit(amount, null)
	
func die() -> void:
	died.emit()
