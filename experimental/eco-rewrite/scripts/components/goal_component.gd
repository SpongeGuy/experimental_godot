extends Node
class_name GoalComponent

@export var goal_name: String = "base_goal"
@export var enabled: bool = true
@export var associated_state: String = ""

var priority: float = 0.0

var brain: BrainComponent
var master_origin: Node2D
var nutrition_component: NutritionComponent
var hunger_component: HungerComponent
var health_component: HealthComponent
var eye_component: EyeComponent

var target: Node2D = null

signal priority_changed(old_priority: float, new_priority: float)
signal goal_completed
signal goal_failed

## evaluate how important this goal is at the current time given current internal state
func evaluate_priority() -> float:
	return 0.0

## calculates the intent for this goal
## returns {direction: Vector2, action: String, target: Node2D}
func calculate_intent() -> Dictionary:
	return {
		"direction": Vector2.ZERO,
		"action": "",
		"target": null
	}

func is_completed() -> bool:
	return false
	
func has_failed() -> bool:
	return false
	
func on_activated() -> void:
	pass
	
func on_deactivate() -> void:
	pass
	
## called every frame while goal is active
func on_update(delta: float) -> void:
	pass

func update_priority() -> float:
	if not enabled:
		priority = 0.0
		return priority
	
	var old_priority = priority
	priority = evaluate_priority()
	
	if priority != old_priority:
		priority_changed.emit(old_priority, priority)
		
	return priority
	
func get_priority() -> float:
	return priority
	
func set_components(p_brain: BrainComponent):
	brain = p_brain
	master_origin = p_brain.master_origin
	nutrition_component = master_origin.get_node_or_null("NutritionComponent")
	hunger_component = master_origin.get_node_or_null("HungerComponent")
	health_component = master_origin.get_node_or_null("HealthComponent")
	eye_component = master_origin.get_node_or_null("EyeComponent")
