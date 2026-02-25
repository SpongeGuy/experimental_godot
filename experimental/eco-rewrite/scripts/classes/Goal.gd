extends Node
class_name Goal

@export var goal_name: String = "base_goal"
@export var enabled: bool = true
@export var completion_penalty: float = 0.5

var priority_penalty: float = 1.0
@export var penalty_reduce_factor: float = 1.0

func _process(delta: float) -> void:
	priority_penalty = lerp(priority_penalty, 1.0, delta * penalty_reduce_factor)

## evaluate how important this goal is at the current time given current internal state
func evaluate_priority(brain: Brain) -> float:
	return 0.0

## calculates the intent for this goal
## returns Intent object
func generate_intent(brain: Brain) -> Intent:
	var intent = Intent.new()
	return intent

func is_completed() -> bool:
	return false
	
func has_failed() -> bool:
	return false
	
func on_activated() -> void:
	pass
	
func on_deactivate() -> void:
	pass
	

	

