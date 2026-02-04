extends Node2D


@export var storage_bar: HBoxContainer

var food_ui_elements: Dictionary = {}

var storage_visibility_timer: float = 0
var storage_visibility_timer_length: float = 4.5

func _process(delta: float) -> void:
	# slowly fade out bar as time goes on
	
	if storage_visibility_timer <= 0.0:
		storage_bar.modulate = lerp(storage_bar.modulate, Color(1, 1, 1, 0), delta * 5)
	else:
		storage_visibility_timer -= delta
	

func _ready() -> void:
	var index: int = 0
	for element in storage_bar.get_children():
		var core_node = element.find_child("core", false, false)
		var frame_node = element.find_child("frame", false, false)
		if core_node:
			core_node.modulate = Color(1, 1, 1, 0)
		food_ui_elements[index] = {
			"core": core_node,
			"frame": frame_node
		}
		index += 1



func add_to_storage_ui(inventory_component: InventoryStackComponent, item: RigidBody2D) -> void:		
	storage_bar.modulate = Color(1, 1, 1, 1) # make bar visible again
	storage_visibility_timer = storage_visibility_timer_length
	
	var inventory_back: int = inventory_component.get_back_id()
	food_ui_elements[inventory_back]["core"].modulate = Color(item.main_color)
		
func remove_from_storage_ui(inventory_component: InventoryStackComponent, item: RigidBody2D) -> void:
	storage_bar.modulate = Color(1, 1, 1, 1) # make bar visible again
	storage_visibility_timer = storage_visibility_timer_length
	
	var inventory_back: int = inventory_component.get_back_id()
	food_ui_elements[inventory_back + 1]["core"].modulate = Color(1, 1, 1, 0)
