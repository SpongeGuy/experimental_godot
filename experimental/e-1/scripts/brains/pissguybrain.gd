extends DeprecatedBrain
class_name DeprecatedPissGuyBrain

@export var attacking_state: BehaviorState
@export var moving_state: BehaviorState

func _evaluate() -> void:
	if _is_adjacent_to_creature():
		state_machine.switch(attacking_state)
	else:
		state_machine.switch(moving_state)
	
func _is_adjacent_to_creature() -> bool:
	var target_lobe: TargetLobe = get_lobe(TargetLobe)
	if target_lobe.target and target_lobe.targeting:
		return true
	return false

