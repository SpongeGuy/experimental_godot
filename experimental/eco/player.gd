extends RigidBody2D
@onready var inventory: Inventory = $Inventory
@onready var held_item_position: Marker2D = $Sprites/ScaleController/Hand
@onready var sprite_scale_controller: Node2D = $Sprites/ScaleController
@onready var main_sprite: Sprite2D = $Sprites/ScaleController/Main


var facing_direction: Vector2 = Vector2.ZERO

enum MovementState {IDLE, MOVING, PHYSICS}

var movement_state = MovementState.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	

func _process(delta: float) -> void:
	intended_move_direction = get_input_vector()
	handle_item_inputs()
	
func _physics_process(delta: float) -> void:
	update_move_velocity(delta)
	update_total_velocity(delta)	
	update_sprite_facing()
	_update_held_item_position()
	_update_cheek_size(delta)


var time: float = 0
func _update_cheek_size(delta: float) -> void:
	time += delta
	var inventory_capacity_ratio: float = float(inventory.storage.size()) / float(inventory.max_capacity)
	if inventory_capacity_ratio > 0.8:
		main_sprite.frame_coords.y = 2
	elif inventory_capacity_ratio > 0.5:
		main_sprite.frame_coords.y = 1
	else:
		main_sprite.frame_coords.y = 0
	#var size = ((sin(time)+1) / 25) + 0.17 + (0.03 * inventory.storage.size())
	#cheek1.scale = Vector2(size, size)
	#cheek2.scale = Vector2(size, size)


# STATISTICS #-----------------------------------------------------------

var health: float = 5










# ITEM INVENTORY #-------------------------------------------------------
func handle_item_inputs() -> void:
	if Input.is_action_just_pressed("use"):
		_try_pickup()
		_try_grab_from_storage()
		
	if Input.is_action_just_pressed("store"):
		_store_held_item()
		
	if Input.is_action_just_pressed("spit"):
		_spit_item()

var held_item: Node2D = null
@export var spit_force: float = 300.0
@export var held_item_offset: Vector2 = Vector2(24, 0)

func _try_grab_from_storage() -> bool:
	if held_item != null:
		return false
		
	var closest_storage = inventory.get_closest_storage()
	if closest_storage == null:
		return false
	
	if closest_storage.inventory.size() == 0:
		return false
	_take_from_storage(closest_storage)
	return true

func _take_from_storage(storage: Node2D) -> void:
	var item = storage.inventory.pop()
	held_item = item
	if item is RigidBody2D:
		item.freeze = true
		item.physics_collider.disabled = true
	item.reparent(held_item_position)
	item.position = Vector2.ZERO
	item.show()
	EventBus.item_taken_from_storage.emit(storage, item)

func _try_pickup() -> bool:
	if held_item != null:
		return false
	var closest_item = inventory.get_closest_item()
	if closest_item == null:
		return false
	_pickup_item(closest_item)
	return true
	
func _pickup_item(item: Node2D) -> void:
	held_item = item
	inventory.freeze_item(item)
	item.reparent(held_item_position)
	item.position = Vector2.ZERO
	item.show()
	
	
func _store_held_item() -> void:
	if held_item == null:
		return
		
	if inventory.push(held_item):
		held_item = null
	
func _spit_item() -> void:
	var item: RigidBody2D
	if held_item:
		item = held_item
		held_item = null
	else:
		item = inventory.pop()
	
	if item == null:
		return
	
	_eject_item(item)
	
func _eject_item(item: Node2D) -> void:
	item.reparent(get_parent())
	item.global_position = global_position + facing_direction * 16
	
	if inventory.unfreeze_item(item):
		var spit_direction = facing_direction.normalized()
		item.apply_central_impulse(spit_direction * spit_force)
		
	item.show()

func _update_held_item_position() -> void:
	if held_item != null:
		held_item.show()
	










# MOVEMENT #-----------------------------------------------------------

var intended_move_direction: Vector2 = Vector2.ZERO
@export var movement_speed: float = 100.0	
func get_input_vector() -> Vector2:
	var player_intended_velocity: Vector2 = Input.get_vector("move_west", "move_east", "move_north", "move_south").normalized()
	return player_intended_velocity
	
var effect_velocity: Vector2 = Vector2.ZERO
var effect_velocity_decay_factor: float = 0.5
var move_velocity: Vector2 = Vector2.ZERO
var total_velocity: Vector2 = Vector2.ZERO


func update_sprite_facing() -> void:
	if abs(total_velocity.x) < 0.1:
		main_sprite.frame_coords.x = 0
		held_item_position.position = Vector2(2.0, 4.0)
	else:
		main_sprite.frame_coords.x = 1
		held_item_position.position = Vector2(5.0, 2.0)
		if total_velocity.x < 0:
			# moving left
			sprite_scale_controller.scale.x = -1
			
		elif total_velocity.x > 0:
			# moving right
			sprite_scale_controller.scale.x = 1
		

func update_move_velocity(delta: float) -> void:
	move_velocity = intended_move_direction * movement_speed
	
	
	facing_direction = intended_move_direction.normalized() # THIS MIGHT BE CHANGED LATER
	
	
	move(delta)

func update_total_velocity(delta: float) -> void:
	effect_velocity = lerp(effect_velocity, Vector2.ZERO, effect_velocity_decay_factor * delta)
	total_velocity = lerp(total_velocity, effect_velocity + move_velocity, 0.25)

## Applies the current velocity with sliding on collisions using move_and_collide().
func move(delta: float) -> void:
	var motion = total_velocity * delta
	var max_slides = 4  # Safety limit to prevent infinite loops in complex geometry
	var slides = 0
	
	while motion != Vector2.ZERO and slides < max_slides:
		var collision = move_and_collide(motion)
		if collision == null:
			break  # No collision, full motion applied
		
		# Slide the remaining motion along the wall
		motion = collision.get_remainder().slide(collision.get_normal())
		slides += 1
