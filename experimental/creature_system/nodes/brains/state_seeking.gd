extends AIState

@export var wander_state: AIState

func enter(creature: Creature) -> void:
	super.enter(creature)
	if creature.polygon:
		creature.polygon.scale = Vector2(1.0, 1.0)
		creature.polygon.color = Color(0, 1, 0, 1)
		
func exit(creature: Creature) -> void:
	super.exit(creature)

func update(creature: Creature, delta: float) -> AIState:
	super.update(creature, delta)
	creature.label_text = "seeking"
	creature.debug_label.text = creature.label_text
	if randf() < 0.05:
		return wander_state
	return null

