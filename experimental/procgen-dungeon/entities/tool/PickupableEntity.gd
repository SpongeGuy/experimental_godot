extends Entity
class_name PickupableEntity

@export_group("Kinetic Damage")
@export var kinetic_hurtbox: KineticHurtbox
@export var do_kinetic_damage: bool = true
@export var min_damage_velocity: float = 150.0
@export var scale_per_speed: float = 200
@export var max_hurtbox_scale: float = 2
@export var base_kinetic_damage: float = 1
@export var damage_per_speed: float = 400
@export var max_kinetic_damage: float = 30
var _potential_kinetic_damage: float = 0
var _last_thrower: Entity = null
var _last_thrower_timer: float = 0.0
var _last_thrower_timer_duration: float = 1.0

func set_last_thrower(thrower: Entity) -> void:
	_last_thrower_timer = _last_thrower_timer_duration
	_last_thrower = thrower

func _nullify_last_thrower(delta: float) -> void:
	if linear_velocity.distance_squared_to(Vector2.ZERO) >= 1:
		if _last_thrower_timer > 0.0:
			_last_thrower_timer = _last_thrower_timer_duration
		return
	if linear_velocity.distance_squared_to(Vector2.ZERO) <= 0.1:
		_last_thrower_timer = max(_last_thrower_timer - delta, 0.0)
	if _last_thrower_timer <= 0.0:
		_last_thrower = null

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 16
	super._ready()
	
func _handle_kinetic_hurtbox() -> void:
	if not kinetic_hurtbox:
		return
	
	kinetic_hurtbox.scale = Vector2.ONE
	kinetic_hurtbox.collision_shape.disabled = true
	
	if not do_kinetic_damage or is_held:
		return
		
	var speed = linear_velocity.length()
	if speed < min_damage_velocity:
		return
	
	var speed_above_minimum = speed - min_damage_velocity
	var extra_scale = speed_above_minimum / scale_per_speed
	var scale_factor = 1.0 + extra_scale
	scale_factor = min(scale_factor, max_hurtbox_scale)
	
	var extra_damage = speed_above_minimum / damage_per_speed
	_potential_kinetic_damage = min(base_kinetic_damage + extra_damage, max_kinetic_damage)
	
	kinetic_hurtbox.scale = Vector2.ONE * scale_factor
	kinetic_hurtbox.collision_shape.disabled = false
		
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_handle_kinetic_hurtbox()
	_nullify_last_thrower(delta)
	# Automatically clean up invalid items every frame
	_cleanup_inventory()

@export_group("Inventory")
@export var inventory: Array[PickupableEntity] = []
@export var inventory_size: int = 3
@export var hold_offset: Vector2 = Vector2(0, -10)
@export var can_be_picked: bool = true

func add_item_to_inventory(item: PickupableEntity) -> void:
	if inventory.size() >= inventory_size:
		return
	
	# Set held state first (this reparents the item)
	item.set_held_state(true, self)
	
	# Connect to item's tree_exiting signal to clean up if it gets freed
	if not item.tree_exiting.is_connected(_on_inventory_item_freed):
		item.tree_exiting.connect(_on_inventory_item_freed.bind(item))
	
	# Add to inventory after reparenting
	inventory.append(item)
	
	# Update positions
	call_deferred("_update_item_positions")

func _on_inventory_item_freed(item: PickupableEntity) -> void:
	# Remove the item from inventory when it's freed
	var index = inventory.find(item)
	if index != -1:
		inventory.remove_at(index)
		_update_item_positions()

func _cleanup_inventory() -> void:
	# Remove any invalid items from inventory
	var cleaned := false
	for i in range(inventory.size() - 1, -1, -1):
		if not is_instance_valid(inventory[i]):
			inventory.remove_at(i)
			cleaned = true
	
	if cleaned:
		_update_item_positions()

func _update_item_positions() -> void:
	# Update positions of all held items
	for i in range(inventory.size()):
		var item = inventory[i]
		if is_instance_valid(item):
			item.global_position = global_position + Vector2(0, -5) + (hold_offset * (i + 1))

func drop_item(index: int, throw_velocity: Vector2 = Vector2.ZERO) -> void:
	if index < 0 or index >= inventory.size():
		return
	
	var item = inventory[index]
	if not is_instance_valid(item):
		inventory.remove_at(index)
		return
	
	# Disconnect the signal
	if item.tree_exiting.is_connected(_on_inventory_item_freed):
		item.tree_exiting.disconnect(_on_inventory_item_freed)
	
	inventory.remove_at(index)
	item.set_held_state(false)
	
	# Apply throw velocity if provided
	if throw_velocity != Vector2.ZERO:
		item.apply_central_impulse(throw_velocity)
		item.set_last_thrower(self)
	
	_update_item_positions()

func drop_all_items(throw_velocity: Vector2 = Vector2.ZERO, spread: bool = true) -> void:
	var items_to_drop = inventory.duplicate()
	inventory.clear()
	
	for i in range(items_to_drop.size()):
		var item = items_to_drop[i]
		if not is_instance_valid(item):
			continue
		
		# Disconnect the signal
		if item.tree_exiting.is_connected(_on_inventory_item_freed):
			item.tree_exiting.disconnect(_on_inventory_item_freed)
		
		item.set_held_state(false)
		
		# Apply throw velocity with optional spread
		if throw_velocity != Vector2.ZERO:
			var final_velocity = throw_velocity
			if spread:
				# Add random angle variation for spread effect
				var angle_offset = randf_range(-PI/4, PI/4)
				final_velocity = throw_velocity.rotated(angle_offset)
			item.linear_velocity = final_velocity
			item.set_last_thrower(self)

# Convenience function to drop the most recent item
func drop_last_item(throw_velocity: Vector2 = Vector2.ZERO) -> void:
	if inventory.size() > 0:
		drop_item(inventory.size() - 1, throw_velocity)

var is_held: bool = false

func set_held_state(held: bool, holder: PickupableEntity = null) -> void:
	is_held = held
	if held:
		physics_box.disabled = true
		linear_velocity = Vector2.ZERO
		set_bt_player_active(false)
		if holder:
			reparent(holder)
		if hitbox:
			hitbox.collision_shape.disabled = true
	else:
		physics_box.disabled = false
		set_bt_player_active(true)
		reparent(EntityManager.get_world())
		if hitbox:
			hitbox.collision_shape.disabled = false

func set_bt_player_active(active: bool) -> void:
	if bt_player:
		bt_player.active = active

func activate(master: Entity, direction: Vector2) -> bool:
	if abilities["ability_1"]:
		return abilities["ability_1"].try_activate(master, direction)
	return false

func die(killer: Node2D) -> void:
	drop_all_items()
	super.die(killer)
