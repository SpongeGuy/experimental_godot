class_name AIBrain extends Node

@export var initial_state: AIState
var current_state: AIState
@export var navigation_agent: NavigationAgent2D

func _ready() -> void:
	start_first_state(get_parent())
		
func start_first_state(creature: Creature):
	if initial_state:
		current_state = initial_state
		current_state.enter(creature)

# essentially an update function which points to the current state's update function.
# keep in mind the states may also have substates which also could be called.
# if a state returns another state in its update function, then the state will transition
func control(creature: Creature, delta: float) -> void:
	if current_state:
		var next_state = current_state.update(creature, delta)
		if next_state and next_state != current_state:
			transition_to(next_state, creature)
			
# safely transition to another state
func transition_to(state: AIState, creature: Creature) -> void:
	if current_state:
		current_state.exit(creature)
	current_state = state
	current_state.enter(creature)
