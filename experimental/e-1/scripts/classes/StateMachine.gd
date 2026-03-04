extends Node
class_name StateMachine

signal state_switched(old_state: State, new_state: State)

var current_state: State

var data: Dictionary = {}

@export var initial_state: State

func _ready() -> void:
	switch(initial_state)

func _process(delta: float) -> void:
	current_state.update(delta)
	
func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)

func switch(new_state: State) -> void:
	# if new state is on cooldown, then don't switch to it
	
	if new_state.cooldown > 0:
		
		return
	if current_state:
		current_state.exit()
	
	state_switched.emit(current_state, new_state)
	current_state = new_state
	current_state.enter()
	
