extends BehaviorState
class_name FaceTargetUseAbilityState

@export var target_lobe: TargetLobe
@export var facing: FacingComponent
@export var abilities: AbilityManager
@export var input: InputComponent
@export var time_to_use_ability: float = 1
@export var ability_to_use: int = 0

var _timer: float = 0.0

func enter() -> void:
	randomize()
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	facing.change_direction(target_lobe.target.global_position - state_machine.entity.global_position)
	_timer += delta
	if _timer >= time_to_use_ability:
		_timer = 0 - randf_range(0, 1)
		input.press_action(ability_to_use)
		input.release_action(ability_to_use)
	
func exit() -> void:
	pass
