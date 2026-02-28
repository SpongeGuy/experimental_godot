extends Node
class_name State

var state_machine: StateMachine

@export var cooldown: float = 0.0
var cooldown_time: float = 0.0

func _ready() -> void:
	state_machine = get_parent()
	if state_machine is not StateMachine:
		push_error(self, ": parent is not StateMachine!")
		
func _process(delta: float) -> void:
	if cooldown > 0.0:
		cooldown -= delta

func enter() -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	pass
	
func exit() -> void:
	pass
