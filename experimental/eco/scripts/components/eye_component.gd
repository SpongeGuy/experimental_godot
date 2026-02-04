extends Node
class_name EyeComponent

@export var sight_area: Area2D


func get_nearby_items() -> Array[Node2D]:
	var nearby: Array[Node2D] = []
	for body in sight_area.get_overlapping_bodies():
		if body.is_in_group("pickupable"):
			nearby.push_back(body)
	return nearby
	
	
func get_nearby_storage() -> Array[Node2D]:
	var nearby: Array[Node2D] = []
	for area in sight_area.get_overlapping_areas():
		var area_parent = area.get_parent()
		if area_parent.is_in_group("storage"):
			nearby.push_back(area_parent)
	return nearby


func get_closest_storage() -> Node2D:
	var storages = get_nearby_storage()
	if storages.is_empty():
		return null
		
	var closest: Node2D = null
	var closest_distance: float = INF
	
	for s in storages:
		var distance = sight_area.global_position.distance_to(s.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = s
			
	return closest


func get_closest_item() -> Node2D:
	var items = get_nearby_items()
	if items.is_empty():
		return null
		
	var closest: Node2D = null
	var closest_distance: float = INF
	
	for item in items:
		var distance = sight_area.global_position.distance_to(item.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = item
			
	return closest
