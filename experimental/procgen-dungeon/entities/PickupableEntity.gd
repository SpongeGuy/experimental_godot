extends Entity
class_name PickupableEntity

@export_group("Inventory")
@export var inventory: Array[PickupableEntity] = []
@export var inventory_size: int = 3
@export var hold_offset: Vector2 = Vector2(0, -10)
@export var can_be_picked: bool = true

func add_item_to_inventory(item: PickupableEntity) -> void:
	inventory.push_back(item)
	item.set_held_state(true, self)
	item.global_position = global_position + Vector2(0, -5) + (hold_offset * (inventory.size()))
	
func fix_inventory() -> void:
	var temp_inventory: Array[PickupableEntity] = []
	for item in inventory:
		if is_instance_valid(item):
			temp_inventory.append(item)
	inventory = temp_inventory

var is_held: bool = false

func set_held_state(held: bool, holder: PickupableEntity = null) -> void:
	is_held = held
	if held:
		physics_box.disabled = true
		linear_velocity = Vector2.ZERO
		set_bt_player_active(false)
		if holder:
			reparent(holder)
	else:
		physics_box.disabled = false
		set_bt_player_active(true)
		reparent(get_tree().current_scene.get_node("World"))

	
func set_bt_player_active(active: bool) -> void:
	if bt_player:
		bt_player.active = active


