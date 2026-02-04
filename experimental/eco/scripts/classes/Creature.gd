extends RigidBody2D
class_name Creature


var health: float = 5
var max_health: float = 5
var hunger: float = 100.0
var max_hunger: float = 100
var invincible: bool = false
var invincibility_timer: float = 0.0 # STOPWATCH STYLE
var invincibility_timer_length: float = 2.0
var starving_timer: float = 0.0 # STOPWATCH STYLE
var starving_timer_length: float = 5.0

@export var hurt_animation: AnimationPlayer



var hurt_sound = preload("res://assets/sounds/effects/ferret_hurt.wav")

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
	EventBus.creature_damaged.emit(self, amount, null)
	invincibility_timer = invincibility_timer_length
	hurt_animation.play("hurt")
	if health <= 0.0:
		die()
	else:
		AudioManager.play_sound_at_position(hurt_sound, global_position)
	
func heal(amount: float) -> void:
	health += amount
	if health > max_health:
		health = max_health
	
func die() -> void:
	queue_free()
	
var yell_sound = preload("res://assets/sounds/effects/ferret_voice.wav")
func satiate_hunger(amount: float) -> void:
	AudioManager.play_sound_at_position(yell_sound, global_position)
	hunger += amount
	if hunger < 0.0:
		hunger = 0.0
	
func starve_hunger(amount: float) -> void:
	hunger -= amount

## Lowers hunger over time and lowers hunger when moving AND take damage when starving
func lower_hunger_over_time(delta: float) -> void:
	hunger -= delta / 5
	hunger = clamp(hunger, 0, max_hunger)
	if hunger < 0.0:
		take_starving_damage(delta)
	else:
		starving_timer = 0.0

func take_starving_damage(delta: float) -> void:
	starving_timer += delta
	if hunger < 0.0 and starving_timer >= starving_timer_length:
		take_damage(1)
		starving_timer = 0.0
