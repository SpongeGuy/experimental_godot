extends BehaviorState
class_name DeathState

## called once when the state machine does its initial switch to this state
func enter() -> void:
	owner.queue_free()
	
## called every frame while this state is active
func update(delta: float) -> void:
	pass
	
## called every physics frame while this state is active
func physics_update(delta: float) -> void:
	pass
	
## called once when this state is switched from
func exit() -> void:
	pass

