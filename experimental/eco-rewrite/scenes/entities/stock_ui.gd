extends Node2D
@export var label: Label

@export var value: int = 0

@export var inventory_stack_component: InventoryStackComponent

@export var show_duration: float = 2.0

var show_timer: float = 0.0

func _process(delta: float) -> void:
	if show_timer > show_duration:
		modulate = lerp(modulate, Color(1, 1, 1, 0), delta * 5)
	else:
		show_timer += delta


func _on_inventory_stack_component_item_added(item: Node2D) -> void:
	value += 1
	label.text = str(value, "/", inventory_stack_component.max_capacity)
	modulate = Color(1, 1, 1, 1)
	show_timer = 0



func _on_inventory_stack_component_item_removed(item: Node2D) -> void:
	value -= 1
	label.text = str(value, "/", inventory_stack_component.max_capacity)
	modulate = Color(1, 1, 1, 1)
	show_timer = 0
