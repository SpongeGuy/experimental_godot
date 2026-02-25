extends Goal
class_name WanderGoal

@export var tolerance: float = 10.0
@export var wander_radius: float = 150.0
@export var master_origin: Node2D

## evaluate how important this goal is at the current time given current internal state
func evaluate_priority(brain: Brain) -> float:
	return 1.0 * priority_penalty

## calculates the intent for this goal
## returns {direction: Vector2, action: String, target: Node2D}
func generate_intent(brain: Brain) -> Intent:
	var intent = Intent.new()
	intent.action = "move_to_location"
	intent.target_position = _pick_random_point(master_origin.position)
	
	return intent

func _pick_random_point(origin: Vector2) -> Vector2:
	var angle = randf() * TAU
	var distance = randf() * wander_radius
	return origin + Vector2(cos(angle), sin(angle)) * distance
