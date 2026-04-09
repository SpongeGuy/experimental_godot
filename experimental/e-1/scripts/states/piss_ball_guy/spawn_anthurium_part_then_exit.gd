extends BehaviorState
class_name SpawnAnthuriumPartThenExit


@export var time_to_spawn: float = 0.0
@export var exit_state: BehaviorState
var _timer: float = 0.0

func enter() -> void:
	_timer = time_to_spawn
	
func update(delta: float) -> void:
	if _timer > 0:
		_timer -= delta
	
	if _timer <= 0:
		AnthuriumBrain.spawn_needed_part(state_machine.entity.global_position)
		state_machine.switch(exit_state)
	
func physics_update(delta: float) -> void:
	pass
	
func exit() -> void:
	pass
