@tool
extends BTAction

@export var range_min: float = 0

@export var range_max: float = 500

var nav_agent: NavigationAgent2D

func _enter() -> void:
	nav_agent = agent.get_node("NavigationAgent2D")

func _generate_name() -> String:
	return "Select a target position to pathfind to with range: [%s, %s]" % [
		range_min, range_max,
	]

func _tick(delta: float) -> Status:
	var target_pos: Vector2
	var is_good_position: bool = false
	while not is_good_position:
		var angle: float = randf() * TAU
		var rand_distance: float = randf_range(range_min, range_max)
		target_pos = agent.global_position + Vector2(sin(angle), cos(angle)) * rand_distance
		# also calculate if the target_pos is not in a wall here
		is_good_position = true
	nav_agent.target_position = target_pos
	return SUCCESS
