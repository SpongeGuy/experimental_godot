extends Brain
class_name PissGuyBrain

@export var attacking_state: BehaviorState

func _evaluate() -> void:
	if _is_adjacent_to_creature():
		state_machine.switch(attacking_state)
	
func _is_adjacent_to_creature() -> bool:
	var target_lobe: TargetLobe = get_lobe(TargetLobe)
	if target_lobe.target and target_lobe.targeting:
		return true
	return false

