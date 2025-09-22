extends AIState

@export var next_mood: AIState

func enter(creature: Creature) -> void:
	super.enter(creature)
	if creature.polygon:
		creature.polygon.color = Color(1, 0, 0, 1)
		
func exit(creature: Creature) -> void:
	super.exit(creature)

func update(creature: Creature, delta: float) -> AIState:
	super.update(creature, delta)
	creature.label_text += "\naggressive"
	creature.debug_label.text = creature.label_text
	if randf() < 0.05:
		return next_mood
	return null
