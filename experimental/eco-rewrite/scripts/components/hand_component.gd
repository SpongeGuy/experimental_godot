extends Node
class_name HandComponent

var held_item: Item = null
@export var master_origin: Node2D
@export var eye_component: EyeComponent
@export var input_component: InputComponent
@export var toss_force: float = 300.0
@export var held_item_offset: Vector2 = Vector2(0, 5)
@export var hand: Marker2D

signal using_item(item: RigidBody2D)
signal eating_item(item: RigidBody2D)

signal item_taken_from_storage(item: RigidBody2D)
signal item_picked_up(item: RigidBody2D)
signal item_tossed(item: RigidBody2D)

signal toss_handled(handled: bool)

func _reset_item_cast_timer() -> void:
	if not held_item:
		return
		
	if not held_item.ability_component:
		return
		
	held_item.ability_component.reset_cast_timer()

func _try_use_held_item(delta: float):
	if not held_item:
		return
	
	if not held_item.has_method("try_use"):
		return
		
	if held_item.type == Item.Type.TOOL:
		using_item.emit(held_item)
	if held_item.type == Item.Type.FOOD:
		eating_item.emit(held_item)
	
	held_item.try_use(delta, master_origin)
	

func _try_grab_from_storage() -> bool:
	if held_item != null:
		return false
	
	var closest_storage = eye_component.get_closest_storage()
	if closest_storage == null:
		return false
	
	var storage_inventory_component = closest_storage.get_node("InventoryStackComponent")
	if storage_inventory_component == null:
		return false
	
	if storage_inventory_component.size() == 0:
		return false
	_take_from_storage(storage_inventory_component)
	return true

func _take_from_storage(storage_inventory_component: InventoryStackComponent) -> void:
	var item = storage_inventory_component.pop()
	held_item = item
	Item.freeze_item(item)
	
	item.reparent(hand)
	item.position = Vector2.ZERO
	
	item_taken_from_storage.emit(item)

func _try_pickup() -> bool:
	if held_item != null:
		return false
	var closest_item = eye_component.get_closest_item()
	if closest_item == null:
		return false
	_pickup_item(closest_item)
	return true
	
func _pickup_item(item: Node2D) -> void:
	held_item = item
	Item.freeze_item(item)
	item.reparent(hand)
	item.position = Vector2.ZERO
	item.show()
	item_picked_up.emit(item)


func _try_toss_item() -> void:
	var item: RigidBody2D
	if not held_item:
		toss_handled.emit(false)
		return
	item = held_item
	held_item = null
		
	
	_toss_item(item)
	toss_handled.emit(true)

func _toss_item(item: RigidBody2D) -> void:
	item.reparent(EntityManager.entity_container)
	item.global_position = master_origin.global_position + input_component.facing_direction * 16
	
	if Item.unfreeze_item(item):
		var spit_direction = input_component.facing_direction.normalized()
		item.apply_central_impulse(spit_direction * toss_force)
		if item.sprite_physics_component:
			item.sprite_physics_component.apply_force_to_sprite(250)

	item.show()
	item_tossed.emit(item)




