extends GoalComponent
class_name WanderGoal

@export var wander_radius: float = 100.0
var wander_target: Vector2 = Vector2.ZERO


func _ready() -> void:
	goal_name = "wander"
	
func evaluate_priority() -> float:
	return 0.1
	
func calculate_intent() -> Dictionary:
	if master_origin.global_position.distance_to(wander_target) < 10.0 or wander_target == Vector2.ZERO:
		wander_target = master_origin.global_position + Vector2.from_angle(randf() * TAU) * randf() * wander_radius
		
	var direction = (wander_target - master_origin.global_position).normalized()
	return {
		"direction": direction,
		"action": "wander",
		"target": null
	}
