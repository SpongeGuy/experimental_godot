extends State
class_name SimpleMovementUpdateState
## states should only include logic which alters data.
## all other functions should be outsourced to other components, such as visual effects or sounds.

## called once when the state machine does its initial switch to this state

@export var movement: MovementComponent
@export var animator: SpriteAnimator

func enter() -> void:
	if animator:
		animator.load_and_reset_animation("move")
	
## called every frame while this state is active
func update(delta: float) -> void:
	if animator:
		animator.update_animation(delta)
	
## called every physics frame while this state is active
func physics_update(delta: float) -> void:
	movement.physics_update(delta, owner)
	
## called once when this state is switched from
func exit() -> void:
	pass

