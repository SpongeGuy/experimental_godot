extends PanelContainer

@export var target_creature: Node = null

@onready var current_intent_label = $VBoxContainer/CurrentIntent
@onready var personality_display = $VBoxContainer/Personality

func _process(_delta):
	if not target_creature or not is_instance_valid(target_creature):
		return
	
	_update_display()

func set_target(creature: Node):
	target_creature = creature

func _update_display():
	var brain = target_creature.get_node_or_null("Brain")
	if not brain:
		return
	
	# Show current intent
	if brain.current_intent:
		var intent = brain.current_intent
		current_intent_label.text = "Intent: %s (%.1f)\nTarget: %s" % [
			intent.action,
			intent.priority,
			intent.target_entity.name if intent.target_entity else "none"
		]
	

	# Show personality
	personality_display.text = "Personality:\n"
	for key in brain.personality:
		personality_display.text += "  %s: %.2f\n" % [key, brain.personality[key]]
