extends Goal
class_name IdleGoal

## evaluate how important this goal is at the current time given current internal state
func evaluate_priority(brain: Brain) -> float:
	return 0.75

## calculates the intent for this goal
## returns Intent object
func generate_intent(brain: Brain) -> Intent:
	var intent = Intent.new()
	return intent

