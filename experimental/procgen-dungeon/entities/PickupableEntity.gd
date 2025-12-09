extends Entity
class_name PickupableEntity

@export_group("Kinetic Damage")
@export var do_kinetic_damage: bool = true
@export var min_damage_velocity: float = 150.0
@export var damage_per_unit_mass_velocity: float = 0.01
var _last_thrower: Entity = null
var _last_thrower_timer: float = 0.0
var _last_thrower_timer_duration: float = 1.0

func set_last_thrower(thrower: Entity) -> void:
	_last_thrower_timer = _last_thrower_timer_duration
	_last_thrower = thrower

func _nullify_last_thrower(delta: float) -> void:
	print(self, " ", linear_velocity.distance_squared_to(Vector2.ZERO))
	if linear_velocity.distance_squared_to(Vector2.ZERO) >= 1:
		if _last_thrower_timer > 0.0:
			_last_thrower_timer = _last_thrower_timer_duration
		return
	if linear_velocity.distance_squared_to(Vector2.ZERO) <= 0.1:
		_last_thrower_timer = max(_last_thrower_timer - delta, 0.0)
		print(self, _last_thrower_timer)
	if _last_thrower_timer <= 0.0:
		_last_thrower = null

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 16
	super._ready()

func _handle_kinetic_damage() -> void:
	if not do_kinetic_damage or is_held:
		return
		
	var speed = linear_velocity.length()
	if speed < min_damage_velocity:
		return
	
	for body in get_colliding_bodies():
		if body == _last_thrower:
			continue
		if body == self or not body is Creature: # TODO: CHANGE THIS LATER
			continue
		
		var impact_magnitude: float = mass * speed
		var damage = impact_magnitude * damage_per_unit_mass_velocity
		if damage > 0:
			EventBus.try_change_creature_health.emit(body, -damage, self)
		
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_handle_kinetic_damage()
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
		reparent(get_tree().current_scene.get_node("World"))

	
func set_bt_player_active(active: bool) -> void:
	if bt_player:
		bt_player.active = active


