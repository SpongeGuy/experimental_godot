class_name State extends Node

signal transitioned(new_state_name: String)

var entity: Creature

func enter() -> void:
	entity = get_parent().get_parent()
	
func exit() -> void:
	pass
		
func process(delta: float) -> void:
	pass
	
func physics_process(delta: float) -> void:
	pass
	
func transition_to_next(next_state: NodePath) -> void:
	if next_state:
		var next = get_node(next_state)
		if next:
			transitioned.emit(next.name)
