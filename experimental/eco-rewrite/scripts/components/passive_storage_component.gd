extends Node
class_name PassiveStorageComponent

@export var inventory_stack_component: InventoryStackComponent

signal item_taken()
signal item_stored(item: Node2D)

func _item_entered_storage_radius(body: Node2D) -> void:
	if body.is_in_group("pickupable"):
		inventory_stack_component.push(body)
		Item.freeze_item(body)
		item_stored.emit(body)
		
func _item_taken(item: Node2D) -> void:
	item_taken.emit(item)
