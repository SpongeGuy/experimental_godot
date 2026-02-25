# res://debug/creature_debug_panel.gd
extends PanelContainer

@export var target_creature: Node = null

@onready var goal_list = $GoalList

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
	
	
	# Show all goal priorities
	goal_list.clear()
	for goal in brain.goals:
		var priority = goal.evaluate_priority(brain)
		var is_active = brain.current_intent and brain.current_intent.goal_name == goal.name
		var prefix = "> " if is_active else "  "
		goal_list.add_item("%s%s: %.1f" % [prefix, goal.name, priority])
	
