extends Node2D

@export var vbox: VBoxContainer
@export var hbox: HBoxContainer

@export var inventory_stack_component: InventoryStackComponent

var icon_frame = preload("res://assets/textures/sprites/ui/food_ui_frame.png")
var icon_core = preload("res://assets/textures/sprites/ui/food_ui_center.png")

@export var num_of_elements_per_hbox: int = 5
var num_of_hbox: int = 0
var num_of_elements: int = 0

@export var value: int = 0
@export var show_duration: float = 2.0
var show_timer: float = 0.0

var hboxes = []
var elements = []

func _ready() -> void:
	num_of_elements = inventory_stack_component.max_capacity % num_of_elements_per_hbox
	num_of_hbox = inventory_stack_component.max_capacity / num_of_elements_per_hbox
	for i in range(num_of_hbox):
		hboxes.append(_create_hbox(vbox))
		
	for i in range(num_of_hbox):
		for j in range(num_of_elements_per_hbox):
			elements.append(_create_element(hboxes[i]))
			
	if num_of_elements > 0:
		var hbox = _create_hbox(vbox)
		for i in range(num_of_elements):
			elements.append(_create_element(hbox))
			
	for element in elements:
		var core = element.get_node_or_null("Core")
		if not core:
			continue
		core.modulate = Color(1, 1, 1, 0)
			

func _create_hbox(parent: Node) -> HBoxContainer:
	var hbox = HBoxContainer.new()
	parent.add_child(hbox)
	return hbox

func _create_element(parent: Node) -> Control:
	var control: Control = Control.new()
	var sprite_icon_frame: Sprite2D = Sprite2D.new()
	var sprite_icon_core: Sprite2D = Sprite2D.new()
	sprite_icon_frame.name = "Frame"
	sprite_icon_core.name = "Core"
	sprite_icon_frame.texture = icon_frame
	sprite_icon_core.texture = icon_core
	control.add_child(sprite_icon_frame)
	control.add_child(sprite_icon_core)
	parent.add_child(control)
	return control
	
func _process(delta: float) -> void:
	if show_timer > show_duration:
		modulate = lerp(modulate, Color(1, 1, 1, 0), delta * 5)
	else:
		show_timer += delta

func _on_inventory_stack_component_item_added(item: Node2D) -> void:
	var core = elements[value].get_node_or_null("Core")
	if item.main_color:
		core.modulate = item.main_color
	else:
		core.modulate = Color(1, 1, 1, 0)
	value += 1
	
	modulate = Color(1, 1, 1, 1)
	show_timer = 0



func _on_inventory_stack_component_item_removed(item: Node2D) -> void:
	value -= 1
	var core = elements[value].get_node_or_null("Core")
	core.modulate = Color(1, 1, 1, 0)
	

	modulate = Color(1, 1, 1, 1)
	show_timer = 0


