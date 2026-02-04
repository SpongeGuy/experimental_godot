extends Node
class_name StateComponent


@export var state_name: String = "base_state"
@export var enabled: bool = true

# references set by brain
var brain: BrainComponent
var master_origin: Node2D

signal state_entered
signal state_exited

func on_enter() -> void:
	state_entered.emit()
	
func on_exit() -> void:
	state_exited.emit()
	
func on_update(delta: float) -> void:
	pass
	
func get_debug_color() -> Color:
	return Color.WHITE
	
func set_components(p_brain: BrainComponent):
	brain = p_brain
	master_origin = p_brain.master_origin
