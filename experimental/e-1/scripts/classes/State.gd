extends Node
class_name State

var state_machine: StateMachine

func _ready() -> void:
	state_machine = get_parent()
	if state_machine is not StateMachine:
		push_error(self, ": parent is not StateMachine!")

func enter() -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	pass
	
func exit() -> void:
	pass
