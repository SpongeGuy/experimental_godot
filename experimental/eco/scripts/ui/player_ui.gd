extends Node2D

@onready var storage_bar: HBoxContainer = $StorageBar/HBoxContainer
@onready var stomach_icon: Sprite2D = $Stomach

var food_ui_elements: Dictionary = {}


var storage_visibility_timer: float = 0
var storage_visibility_timer_length: float = 4.5

var stomach_visibility_timer: float = 0
var stomach_visibility_timer_length: float = 4.5
var last_stomach_frame: int = 0
func _process(delta: float) -> void:
	update_hunger_icon(delta)
	
	# slowly fade out bar as time goes on
	storage_visibility_timer -= delta
	if storage_visibility_timer < 0.0:
		storage_bar.modulate = lerp(storage_bar.modulate, Color(1, 1, 1, 0), delta * 5)
	

func _ready() -> void:
	EventBus.added_to_inventory.connect(add_to_storage_ui)
	EventBus.removed_from_inventory.connect(remove_from_storage_ui)
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

func update_hunger_icon(delta: float) -> void:
	var player = get_parent()
	var stomach_frame: int = floor(player.hunger / 10)
	var stomach_position: Vector2 = Vector2(14, 9)
	if stomach_visibility_timer > 0.0:
		stomach_visibility_timer -= delta
	stomach_frame = clamp(stomach_frame, 0, stomach_icon.hframes - 1)
	if stomach_frame != last_stomach_frame and stomach_frame >= 0.0:
		stomach_visibility_timer = stomach_visibility_timer_length
		last_stomach_frame = stomach_frame
		stomach_icon.modulate = Color(1, 1, 1, 1)
		
	
	stomach_icon.frame = stomach_frame
	if stomach_frame <= 3:
		stomach_icon.position = stomach_position + Vector2(randf_range(0, 1), randf_range(0, 1))
		if stomach_visibility_timer <= 0.0:
			#stomach_icon.global_position = lerp(stomach_icon.global_position, Vector2(100, 100), delta * 5)
			stomach_icon.modulate = lerp(stomach_icon.modulate, Color(1, 1, 1, 0.3), delta * 5)
	else:
		if stomach_visibility_timer <= 0.0:
			#stomach_icon.global_position = lerp(stomach_icon.global_position, Vector2(100, 100), delta * 5)
			stomach_icon.modulate = lerp(stomach_icon.modulate, Color(1, 1, 1, 0.0), delta * 5)
		
	

func add_to_storage_ui(inventory: Inventory, item: RigidBody2D) -> void:
	if inventory.get_parent() != get_parent():
		return
		
	storage_bar.modulate = Color(1, 1, 1, 1) # make bar visible again
	storage_visibility_timer = storage_visibility_timer_length
	
	var inventory_back: int = inventory.get_back_id()
	food_ui_elements[inventory_back]["core"].modulate = Color(item.main_color)
		
func remove_from_storage_ui(inventory: Inventory, item: RigidBody2D) -> void:
	storage_bar.modulate = Color(1, 1, 1, 1) # make bar visible again
	storage_visibility_timer = storage_visibility_timer_length
	
	var inventory_back: int = inventory.get_back_id()
	food_ui_elements[inventory_back + 1]["core"].modulate = Color(1, 1, 1, 0)
