@tool
extends BTAction

@export var range_min: float = 1
@export var range_max: float = 15
var nav_agent: NavigationAgent2D

func _generate_name() -> String:
	return "Set target_position to random coordinate in range: [%s, %s]" % [
		range_min, range_max,
	]

func _enter() -> void:
	nav_agent = agent.get_node("NavigationAgent2D")

func _tick(_delta: float) -> Status:
	var target_pos: Vector2
	var is_good_position: bool = false
	while not is_good_position:
		var angle: float = randf() * TAU
		var rand_distance: float = randf_range(range_min, range_max)
		target_pos = agent.global_position + Vector2(sin(angle), cos(angle)) * rand_distance
		is_good_position = true
	blackboard.set_var("target_position", target_pos)
	return SUCCESS
