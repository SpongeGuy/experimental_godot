class_name StateMachine extends Node

@export var initial_state: NodePath = ""

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transitioned.conneect(_on_state_transitioned)
		if initial_state:
			current_state = get_node(initial_state)
			current_state.enter()
	pass

func _process(delta: float) -> void:
	if current_state:
		current_state.process(delta)
	
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_process(delta)

func _on_state_transitioned(new_state_name: String) -> void:
	var new_state = states.get(new_state_name)
	if new_state:
		current_state.exit()
		current_state = new_state
		current_state.enter()
