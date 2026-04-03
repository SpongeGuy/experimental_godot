extends BehaviorState
class_name PlayerMoveState
## states should only include logic which alters data.
## all other functions should be outsourced to other components, such as visual effects or sounds.

@export var movement: MovementComponent
@export var input: InputComponent
@export var facing: FacingComponent
@export var idle_state: BehaviorState
@export var animator: SpriteAnimator

var desired_direction: Vector2 = Vector2.ZERO

## called once when the state machine does its initial switch to this state
func enter() -> void:
	if animator:
		animator.load_and_reset_animation("walk_ew")
	
## called every frame while this state is active
func update(delta: float) -> void:
	var direction: Vector2 = facing.get_direction()
	var velocity: Vector2 = movement.velocity
	
	if animator:
		if abs(direction.x) > abs(direction.y):
			animator.load_animation("walk_ew")
		elif direction.y >= 0:
			animator.load_animation("walk_n")
		else:
			animator.load_animation("walk_s")
		animator.animation_speed = velocity.normalized().length()
	
## called every physics frame while this state is active
func physics_update(delta: float) -> void:
	if facing:
		facing.change_direction(desired_direction)
	
	desired_direction = Input.get_vector("west", "east", "north", "south")
	input.set_move_input_direction(desired_direction)
	if abs(desired_direction.length()) < 0.1:
		state_machine.switch(idle_state)
		
	
		
	
		

	
## called once when this state is switched from
func exit() -> void:
	apply_cooldown()

