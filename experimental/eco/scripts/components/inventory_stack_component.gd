extends Node
class_name InventoryStackComponent


var storage: Array[Node2D] = []

@export var max_capacity: int = 5

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
	
func get_back_id() -> int:
	if storage.is_empty():
		return -1
	var id: int = 0
	var back = storage.back()
	id = storage.rfind(back)
	return id



