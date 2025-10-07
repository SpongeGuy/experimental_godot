class_name AIState extends Node

@export var sub_state: AIState

func enter(creature: Creature) -> void:
	# override this and add instructions to occur once when the state is entered
	
	# possible substate control
	if sub_state:
		sub_state.enter(creature)
		
func exit(creature: Creature) -> void:
	# override this and add instructions to occur once when the state is exited
	
	# possible substate control
	if sub_state:
		sub_state.exit(creature)

func update(creature: Creature, delta: float) -> AIState:
	# override this to add instructions to be called every frame
	
	# possible substate control
	if sub_state:
		var sub_next = sub_state.update(creature, delta)
		if sub_next and sub_next != sub_state:
			sub_state.exit(creature)
			sub_state = sub_next
			sub_state.enter(creature)
	return null
