extends State
class_name PlayerMoveState
## states should only include logic which alters data.
## all other functions should be outsourced to other components, such as visual effects or sounds.

@export var movement: MovementComponent
@export var facing: FacingComponent
@export var idle_state: State
@export var animator: SpriteAnimator

var desired_direction: Vector2 = Vector2.ZERO

## called once when the state machine does its initial switch to this state
func enter() -> void:
	if animator:
		animator.load_and_reset_animation("walk_ew")
	
## called every frame while this state is active
func update(delta: float) -> void:
	var velocity: Vector2 = movement.get_actual_velocity()
	
	if animator:
		if abs(velocity.x) > abs(velocity.y):
			animator.load_animation("walk_ew")
		elif velocity.y >= 0:
			animator.load_animation("walk_n")
		else:
			animator.load_animation("walk_s")
		animator.update_animation(delta)
	
## called every physics frame while this state is active
func physics_update(delta: float) -> void:
	if facing:
		facing.change_direction(desired_direction)
	
	desired_direction = Input.get_vector("west", "east", "north", "south")
	movement.set_desired_direction(desired_direction)
	movement.physics_update(delta, owner)
	if abs(desired_direction.length()) < 0.1:
		state_machine.switch(idle_state)
		
	
		
	
		

	
## called once when this state is switched from
func exit() -> void:
	pass

