extends Node
class_name HungerComponent

signal starve(amount: float)

@export var hunger: float = 100.0
@export var max_hunger: float = 100
@export var hunger_rate: float = 1.0
@export var starving_timer: float = 0.0 # STOPWATCH STYLE
@export var starving_timer_length: float = 5.0
@export var starve_damage: float = 1.0
	
func _process(delta: float) -> void:
	lower_hunger_over_time(delta)

func satiate_hunger(amount: float) -> void:
	hunger += amount
	if hunger < 0.0:
		hunger = 0.0
	
func starve_hunger(amount: float) -> void:
	hunger -= amount

## Lowers hunger over time and lowers hunger when moving AND take damage when starving
func lower_hunger_over_time(delta: float) -> void:
	hunger -= (delta / 5) * hunger_rate
	hunger = clamp(hunger, 0, max_hunger)
	if hunger < 0.0:
		take_starving_damage(delta)
	else:
		starving_timer = 0.0

func take_starving_damage(delta: float) -> void:
	starving_timer += delta
	if hunger < 0.0 and starving_timer >= starving_timer_length:
		starve.emit(starve_damage)
		starving_timer = 0.0
