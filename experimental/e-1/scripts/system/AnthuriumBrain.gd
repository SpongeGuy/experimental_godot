extends Node


var active_anthurium_parts: Dictionary[StringName, int] = {}

func add_active_part(name: StringName) -> void:
	if not active_anthurium_parts.has(name):
		active_anthurium_parts.set(name, 1)
	else:
		active_anthurium_parts[name] += 1
	
func remove_active_part(name: StringName) -> void:
	active_anthurium_parts[name] -= 1
	
func resolve_needed_part() -> StringName:
	if not &"anthurium_core" in active_anthurium_parts:
		return &"anthurium_core"
	return &"anthurium_grass"
		

func spawn_needed_part(pos: Vector2) -> void:
	var name: StringName = resolve_needed_part()
	EntityManager.spawn_safely(name, pos)
