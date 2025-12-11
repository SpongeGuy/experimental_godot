extends Entity
class_name PickupableEntity

@export_group("Kinetic Damage")
@export var kinetic_hurtbox: KineticHurtbox
@export var do_kinetic_damage: bool = true
@export var min_damage_velocity: float = 150.0
@export var scale_per_speed: float = 200 ## +1 scale per unit pixel/second travelled
@export var max_hurtbox_scale: float = 2
@export var base_kinetic_damage: float = 1
@export var damage_per_speed: float = 400 ## +1 damage per unit pixel/second travelled
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
		reparent(EntityManager.get_world())

	
func set_bt_player_active(active: bool) -> void:
	if bt_player:
		bt_player.active = active


