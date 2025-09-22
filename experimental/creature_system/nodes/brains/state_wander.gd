extends AIState

@export var seeking_state: AIState

func enter(creature: Creature) -> void:
	super.enter(creature)
	if creature.polygon:
		creature.polygon.scale = Vector2(1.2, 1.2)
		
func exit(creature: Creature) -> void:
	super.exit(creature)

func update(creature: Creature, delta: float) -> AIState:
	super.update(creature, delta)
	creature.label_text = "wandering"
	creature.debug_label.text = creature.label_text
	if randf() < 0.05:
		return seeking_state
	return null
