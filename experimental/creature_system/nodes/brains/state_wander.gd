extends AIState

@export var seeking_state: AIState

func enter(creature: Creature) -> void:
	super.enter(creature)
		
func exit(creature: Creature) -> void:
	super.exit(creature)

func update(creature: Creature, delta: float) -> AIState:
	super.update(creature, delta)
	if randf() < 0.05:
		return seeking_state
	return null
