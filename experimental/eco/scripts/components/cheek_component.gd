extends Node

@export var spit_force: float = 600.0
@export var store_item_timer: float = 0.0 # STOPWATCH STYLE
@export var store_item_timer_length: float = 2.0
@export var hand_component: HandComponent
@export var inventory: InventoryStackComponent
@export var movement_component: MovementComponent

func _try_store_item(delta: float) -> void:
	# player must be not moving and have a valid held item in their hand 
	# to store items
	# this method should only be called in handle_inputs()
	var total_velocity: Vector2 = movement_component.total_velocity
	var is_stopped: bool = abs(total_velocity.x) < 0.1 and abs(total_velocity.y) < 0.1
	if not inventory.is_full() and hand_component.held_item and is_stopped:
		store_item_timer += delta
		hand_component.held_item_position.position += Vector2(randf_range(-1, 1), randf_range(-1, 1))
		if store_item_timer > store_item_timer_length:
			_store_held_item()
	else:
		store_item_timer = 0

func _store_held_item() -> void:
	# push held item to inventory and set held_item to null
	
	if hand_component.held_item == null:
		return
		
	if inventory.push(hand_component.held_item):
		EventBus.added_to_inventory.emit(inventory, hand_component.held_item)
		hand_component.held_item = null
	
func _try_spit_item() -> void:
	var item: RigidBody2D

	item = inventory.pop()
	if item:
		EventBus.removed_from_inventory.emit(inventory, item)
	if item == null:
		return
	_spit_item(item)
	
func _spit_item(item: Node2D) -> void:
	item.reparent(get_parent())
	item.global_position = hand_component.eye_component.sight_area.global_position + hand_component.input_component.facing_direction * 16
	if inventory.unfreeze_item(item):
		var spit_direction = hand_component.input_component.facing_direction.normalized()
		item.apply_central_impulse(spit_direction * spit_force)
		item.apply_force_to_sprite(250)
	item.show()
