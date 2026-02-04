extends Node
class_name CheekComponent

@export var master_origin: Node2D
@export var hand_component: HandComponent
@export var inventory_component: InventoryStackComponent
@export var movement_component: MovementComponent
@export var spit_force: float = 600.0
@export var store_item_timer: float = 0.0 # STOPWATCH STYLE
@export var store_item_timer_length: float = 2.0

signal storing_item(item: RigidBody2D)

signal item_stored(item: RigidBody2D)
signal item_spit(item: RigidBody2D)

@export var spit_sound: AudioStream
@export var store_sound: AudioStream

signal added_to_inventory(inventory_component: InventoryStackComponent, item: RigidBody2D)
signal removed_from_inventory(inventory_component: InventoryStackComponent, item: RigidBody2D)

func _try_store_item(delta: float) -> void:
	# player must be not moving and have a valid held item in their hand 
	# to store items
	# this method should only be called in handle_inputs()
	var total_velocity: Vector2 = movement_component.total_velocity
	var is_stopped: bool = abs(total_velocity.x) < 0.1 and abs(total_velocity.y) < 0.1
	if not inventory_component.is_full() and hand_component.held_item and is_stopped:
		store_item_timer += delta
		storing_item.emit(hand_component.held_item)
		if store_item_timer > store_item_timer_length:
			_store_held_item()
	else:
		store_item_timer = 0

func _store_held_item() -> void:
	# push held item to inventory and set held_item to null
	
	if hand_component.held_item == null:
		return
		
	if inventory_component.push(hand_component.held_item):
		added_to_inventory.emit(inventory_component, hand_component.held_item)
		AudioManager.play_sound_at_position(store_sound, master_origin.global_position)
		item_stored.emit(hand_component.held_item)
		hand_component.held_item = null
		
	
func _try_spit_item() -> void:
	var item: RigidBody2D
	if hand_component.held_item:
		return
	item = inventory_component.pop()
	if item:
		removed_from_inventory.emit(inventory_component, item)
	if item == null:
		return
	_spit_item(item)
	
func _spit_item(item: Node2D) -> void:
	item.reparent(EntityManager.entity_container)
	item.global_position = master_origin.global_position + hand_component.input_component.facing_direction * 16
	if Item.unfreeze_item(item):
		var spit_direction = hand_component.input_component.facing_direction.normalized()
		item.apply_central_impulse(spit_direction * spit_force)
		if item.sprite_physics_component:
			item.sprite_physics_component.apply_force_to_sprite(250)
		AudioManager.play_sound_at_position(spit_sound, master_origin.global_position)
	
	item_spit.emit(item)
