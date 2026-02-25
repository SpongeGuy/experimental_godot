extends Goal
class_name SeekFoodGoal

@export var hunger_component: HungerComponent

## evaluate how important this goal is at the current time given current internal state
func evaluate_priority(brain: Brain) -> float:
	return get_multiplier_adjusted(hunger_component.hunger, hunger_component.max_hunger, 0.2, 1, true)

## calculates the intent for this goal
## returns Intent object
func generate_intent(brain: Brain) -> Intent:
	var intent = Intent.new()
	return intent

func get_multiplier_adjusted(current_value: float, max_value: float, range_min: float, range_max: float, inverse: bool = false) -> float:
	if max_value <= 0:
		return range_max
	
	var ratio: float = clampf(current_value / max_value, 0.0, 1.0)
	
	if inverse:
		ratio = 1.0 - ratio
	
	return lerp(range_min, range_max, ratio)
