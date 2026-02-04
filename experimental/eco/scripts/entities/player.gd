extends Creature
@onready var inventory: Inventory = $Inventory
@onready var held_item_position: Marker2D = $Hand
@onready var sprite_scale_controller: Node2D = $Sprites/ScaleController
@onready var main_sprite: Sprite2D = $Sprites/ScaleController/Main



var facing_direction: Vector2 = Vector2.ZERO

enum MovementState {IDLE, MOVING, PHYSICS}

var movement_state = MovementState.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	
	EntityManager.player_character = self
	

func _process(delta: float) -> void:
	intended_move_direction = get_input_vector()
	handle_inputs(delta)
	lower_hunger_over_time(delta)
	_update_cheek_size(delta)
	_update_held_item_position()
	update_invincibility(delta)
	
func _physics_process(delta: float) -> void:
	update_move_velocity(delta)
	update_total_velocity(delta)
	update_sprite_facing()
	
	




# STATISTICS #-----------------------------------------------------------


	






# INPUTS CONTROLS AND THE LIKE #-------------------------------------------------------

enum InputBehavior{IDLE, EATING, STORING}
var input_behavior: InputBehavior

func handle_inputs(delta: float) -> void:
	input_behavior = InputBehavior.IDLE
	
	if not is_instance_valid(held_item):
		held_item = null
	
	if holding_interact:
		_try_store_item(delta)
	
	if Input.is_action_just_pressed("interact"):
		_try_pickup()
		_try_grab_from_storage()
		
	if holding_use:
		_try_use_held_item(delta)
		
	if Input.is_action_just_pressed("toss"):
		_try_eject_item()
		
	

var held_item: Node2D = null
@export var toss_force: float = 300.0
@export var held_item_offset: Vector2 = Vector2(24, 0)
@export var spit_force_multiplier: float = 2.5

func _try_use_held_item(delta: float) -> void:
	if not held_item:
		return
	
	if not held_item.has_method("use"):
		return
		
	var using: bool = held_item.try_use(delta, self)
	held_item_position.position += Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
	if held_item is Fruit:
		input_behavior = InputBehavior.EATING

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
	inventory.freeze_item(item)
	item.reparent(held_item_position)
	item.position = Vector2.ZERO
	item.show()
	EventBus.item_taken_from_storage.emit(storage, item)
	AudioManager.play_sound_at_position(pickup_sound, global_position)

func _try_pickup() -> bool:
	if held_item != null:
		return false
	var closest_item = inventory.get_closest_item()
	if closest_item == null:
		return false
	_pickup_item(closest_item)
	return true
	
var pickup_sound = preload("res://assets/sounds/effects/pickup.wav")
func _pickup_item(item: Node2D) -> void:
	held_item = item
	inventory.freeze_item(item)
	item.reparent(held_item_position)
	item.position = Vector2.ZERO
	item.show()
	AudioManager.play_sound_at_position(pickup_sound, global_position)
	
var store_sound = preload("res://assets/sounds/effects/store.wav")

func _try_store_item(delta: float) -> void:
	# player must be not moving and have a valid held item in their hand 
	# to store items
	# this method should only be called in handle_inputs()
	
	var is_stopped: bool = abs(total_velocity.x) < 0.1 and abs(total_velocity.y) < 0.1
	if not inventory.is_full() and held_item and is_stopped:
		input_behavior = InputBehavior.STORING
		store_item_timer += delta
		held_item_position.position += Vector2(randf_range(-1, 1), randf_range(-1, 1))
		if store_item_timer > store_item_timer_length:
			_store_held_item()
	else:
		store_item_timer = 0

func _store_held_item() -> void:
	# push held item to inventory and set held_item to null
	
	if held_item == null:
		return
		
	if inventory.push(held_item):
		EventBus.added_to_inventory.emit(inventory, held_item)
		held_item = null
	AudioManager.play_sound_with_random_pitch(store_sound, global_position, 0.7, 1.3)
	
var spit_sound = preload("res://assets/sounds/effects/spit.wav")
func _try_eject_item() -> void:
	var item: RigidBody2D
	var item_was_spit: bool = false
	if held_item:
		item = held_item
		held_item = null
	else:
		item_was_spit = true
		item = inventory.pop()
		if item:
			EventBus.removed_from_inventory.emit(inventory, item)
	if item == null:
		return
	
	if item_was_spit:
		AudioManager.play_sound_at_position(spit_sound, global_position)
	_eject_item(item, item_was_spit)
	
	
var throw_sound = preload("res://assets/sounds/effects/throw.wav")
var drop_sound = preload("res://assets/sounds/effects/drop.wav")
func _eject_item(item: Node2D, item_was_spit: bool) -> void:
	
	var total_toss_force: float = toss_force
	
	if item_was_spit:
		total_toss_force *= spit_force_multiplier
	
	item.reparent(get_parent())
	item.global_position = global_position + facing_direction * 16
	
	if inventory.unfreeze_item(item):
		var spit_direction = facing_direction.normalized()
		item.apply_central_impulse(spit_direction * total_toss_force)
		item.apply_force_to_sprite(250)
		if facing_direction != Vector2.ZERO:
			AudioManager.play_sound_with_random_pitch(throw_sound, global_position, 0.7, 1.3)
		else:
			AudioManager.play_sound_at_position(drop_sound, global_position)
	item.show()
	

func _update_held_item_position() -> void:
	if held_item != null:
		held_item.show()

var holding_interact: bool = false
var store_item_timer: float = 0.0 # STOPWATCH STYLE
var store_item_timer_length: float = 2.0

var holding_use: bool = false



func _input(event):
	if event.is_action_pressed("interact"):
		holding_interact = true
	if event.is_action_released("interact"):
		holding_interact = false
	
	if event.is_action_pressed("use"):
		holding_use = true
	if event.is_action_released("use"):
		holding_use = false









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
var movement_modifier: float = 1.0

		
func update_move_velocity(delta: float) -> void:
	movement_modifier = max(movement_modifier, 0.0)
	move_velocity = intended_move_direction * movement_speed * movement_modifier
	
	
	#facing_direction = intended_move_direction.normalized() # THIS MIGHT BE CHANGED LATER
	var mouse_pos: Vector2 = get_global_mouse_position()
	facing_direction = (mouse_pos - global_position).normalized()
	move(delta)
	movement_modifier = 1.0

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

















# COSMETIC # ---------------------------------------------

var hand_positions: Dictionary = {
	"idle": Vector2(3.0, 2.0),
	"move_left": Vector2(-5.0, 1.0),
	"move_right": Vector2(5.0, 1.0)
}

var mouth_positions: Dictionary = {
	"idle": Vector2(0.0, -5.0),
	"move_left": Vector2(-4.0, -5.0),
	"move_right": Vector2(4.0, -5.0)
}

func update_sprite_facing() -> void:
	if abs(total_velocity.x) < 0.1:
		# stopped
		main_sprite.frame_coords.x = 0
		if input_behavior == InputBehavior.EATING or input_behavior == InputBehavior.STORING:
			held_item_position.position = lerp(held_item_position.position, mouth_positions["idle"], 0.1)
		else:
			held_item_position.position = lerp(held_item_position.position, hand_positions["idle"], 0.1)
	else:
		# moving
		main_sprite.frame_coords.x = 1
		
		if total_velocity.x < 0:
			# moving left
			sprite_scale_controller.scale.x = -1
			if input_behavior == InputBehavior.EATING or input_behavior == InputBehavior.STORING:
				held_item_position.position = lerp(held_item_position.position, mouth_positions["move_left"], 0.1)
			else:
				held_item_position.position = lerp(held_item_position.position, hand_positions["move_left"], 0.5)
			
		elif total_velocity.x > 0:
			# moving right
			sprite_scale_controller.scale.x = 1
			if input_behavior == InputBehavior.EATING or input_behavior == InputBehavior.STORING:
				held_item_position.position = lerp(held_item_position.position, mouth_positions["move_right"], 0.1)
			else:
				held_item_position.position = lerp(held_item_position.position, hand_positions["move_right"], 0.5)


func _update_cheek_size(delta: float) -> void:
	var inventory_capacity_ratio: float = float(inventory.storage.size()) / float(inventory.max_capacity)
	if inventory_capacity_ratio > 0.8:
		main_sprite.frame_coords.y = 2
	elif inventory_capacity_ratio > 0.5:
		main_sprite.frame_coords.y = 1
	else:
		main_sprite.frame_coords.y = 0
