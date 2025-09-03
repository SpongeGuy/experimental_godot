class_name Creature extends CharacterBody2D

@export var creature_stats: CreatureResource
@export var attack: Weapon
@export var ability: Weapon

func _scan_nearby(area: Area2D) -> Array:
	return area.get_overlapping_bodies()
	
func _prioritize_target(nearby: Array) -> Node2D:
	for node in nearby:
		if node.is_in_group("fruit") and is_in_group("herbivore"):
			return node
		if node.is_in_group("player") and is_in_group("evil"):
			return node
	return nearby[0] if nearby.size() > 0 else null

