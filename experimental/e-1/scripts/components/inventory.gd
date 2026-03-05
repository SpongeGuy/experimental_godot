extends Node
class_name Inventory

@export var inventory_capacity: int = 10
var inventory: Array[Node2D] = []
var inventory_item_collision_data: Dictionary

func put_into_inventory(item: CollisionObject2D) -> void:
	# hide item
	# freeze item's interactions and physics and behavior
	# item must have a stashablecomponent to be put into an inventory
	pass
	
func take_from_inventory(item: CollisionObject2D) -> void:
	pass
	
func take_from_inventory_stack() -> void:
	pass

