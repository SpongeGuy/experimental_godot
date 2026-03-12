extends State
class_name PlopState

@export var orb_scene: PackedScene
@export var animator: SpriteAnimator
@export var exit_state: State

@export var time_to_plop: float = 3.0
var plop_timer: float = 0.0

func enter() -> void:
	if animator:
		animator.load_and_reset_animation("plop")
	
func update(delta: float) -> void:
	plop_timer += delta
	if plop_timer >= time_to_plop:
		var orbo = orb_scene.instantiate()
		orbo.global_position = owner.global_position
		GameManager.add_entity(orbo)
		plop_timer = 0.0
		state_machine.switch(exit_state)
	
func physics_update(delta: float) -> void:
	if animator:
		animator.update_animation(delta)
	
func exit() -> void:
	pass
