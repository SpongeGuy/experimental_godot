extends State
class_name PlayerMoveState
## states should only include logic which alters data.
## all other functions should be outsourced to other components, such as visual effects or sounds.

@export var movement: MovementComponent
@export var facing: FacingComponent
@export var idle_state: State
@export var animator: SpriteAnimator

## called once when the state machine does its initial switch to this state
func enter() -> void:
	if animator:
		animator.load_animation("walk")
	
## called every frame while this state is active
func update(delta: float) -> void:
	if animator:
		animator.update_animation(delta)
	
## called every physics frame while this state is active
func physics_update(delta: float) -> void:
	var desired_direction: Vector2 = Input.get_vector("west", "east", "north", "south")
	movement.set_desired_direction(desired_direction)
	movement.physics_update(delta, owner)
	if abs(desired_direction.length()) < 0.1:
		state_machine.switch(idle_state)
		
	if facing:
		facing.change_direction(desired_direction)
		
	
	
## called once when this state is switched from
func exit() -> void:
	pass

