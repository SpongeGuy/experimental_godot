class_name Inventory
extends Node2D


var storage: Array[Node2D] = []

@export var max_capacity: int = 10

@export var pickup_area: Area2D

func _ready() -> void:
	pass
	
func push(item: Node2D) -> bool:
	if is_full():
		return false
	storage.push_back(item)
	item.hide()
	return true
	
func pop() -> Node2D:
	if is_empty():
		return null
		
	var item = storage.pop_back()
	return item	
	
func peek() -> Node2D:
	if is_empty():
		return null
	return storage[-1]
	
func size() -> int:
	return storage.size()
	
func is_empty() -> bool:
	return storage.is_empty()
	
func is_full() -> bool:
	return storage.size() >= max_capacity
	
func clear() -> void:
	storage.clear()

func freeze_item(item: Node2D) -> bool:
	if item is RigidBody2D:
		item.process_mode = Node.PROCESS_MODE_DISABLED
		item.freeze = true
		item.physics_collider.disabled = true
		return true
	return false
		
func unfreeze_item(item: Node2D) -> bool:
	if item is RigidBody2D:
		item.process_mode = Node.PROCESS_MODE_INHERIT
		item.freeze = false
		item.physics_collider.disabled = false
		return true
	return false
	
func get_nearby_items() -> Array[Node2D]:
	var nearby: Array[Node2D] = []
	for body in pickup_area.get_overlapping_bodies():
		if body.is_in_group("pickupable"):
			nearby.push_back(body)
	return nearby
	
func get_nearby_storage() -> Array[Node2D]:
	var nearby: Array[Node2D] = []
	for area in pickup_area.get_overlapping_areas():
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
		var distance = global_position.distance_to(s.global_position)
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
		var distance = global_position.distance_to(item.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = item
			
	return closest
