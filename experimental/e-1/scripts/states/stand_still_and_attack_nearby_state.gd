extends State
class_name StandStillAndAttackNearbyState

@export var radius: float = 25.0
@export var exit_state: State
@export var ability: Ability
@export var facing: FacingComponent
@export var animator: SpriteAnimator

@export var timer_length: float = 3.0
@export var attack_radius: float = 16.0
var hit_time: float = 0.0
var hit_target: Node2D

signal interrupted()

func enter() -> void:
	if state_machine.data.has("object"):
		hit_target = state_machine.data.object
		
	interrupted.connect(_on_interrupted)
	hit_time = 0.0
	
	if animator:
		animator.load_animation("attack")
	
func update(delta: float) -> void:
	if not is_instance_valid(hit_target):
		interrupted.emit()
		return
	
	
	if hit_target.global_position.distance_to(owner.global_position) > attack_radius:
		interrupted.emit()
	
	hit_time -= delta
	
	if hit_time <= 0.0:
		hit_time = timer_length
		ability.execute()
		if animator:
			animator.reset_animation()
	
func physics_update(delta: float) -> void:
	if facing and hit_target:
		facing.change_direction((hit_target.global_position - owner.global_position).normalized())
		
	if animator:
		animator.update_animation(delta)
	
func exit() -> void:
	interrupted.disconnect(_on_interrupted)
	

func _on_interrupted() -> void:
	state_machine.switch(exit_state)
