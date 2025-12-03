extends RigidBody2D
class_name Entity

@export var abilities: Dictionary[String, Ability] = {
	"ability_p": null, # pick up ability
	"ability_t": null, # toss / drop ability
	"ability_u": null, # use ability (for items currently picked up)
	# passive, active, movement abilities unique to entity
	"ability_1": null,
	"ability_2": null,
	"ability_3": null,
	"ability_4": null,
}

func _setup_physics_properties() -> void:
	if freeze:
		bt_player.active = true
	else:
		bt_player.active = false
	
	physics_material_override = PhysicsMaterial.new()
	gravity_scale = 0
	lock_rotation = true

var nearby_bodies: Array[Entity] = []

@export var facing_direction: Vector2

@export var inventory: Array[Entity] = []
@export var inventory_size: int = 3
@export var hold_offset: Vector2 = Vector2(0, -10)
@export var can_be_picked: bool = true

func add_item_to_inventory(item: Entity) -> void:
	inventory.push_back(item)
	item.set_held_state(true, self)
	item.global_position = global_position + Vector2(0, -5) + (hold_offset * (inventory.size()))
	
func fix_inventory() -> void:
	var temp_inventory: Array[Entity] = []
	for item in inventory:
		if is_instance_valid(item):
			temp_inventory.append(item)
	inventory = temp_inventory

var is_held: bool = false

func set_held_state(held: bool, holder: Entity = null) -> void:
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


@export_category("References")
@export var physics_box: CollisionShape2D
@export var bt_player: BTPlayer
@export var graphical_module: Node2D
@export_group("Areas")
@export var hitbox: Hitbox
@export var hurtbox: Hurtbox
@export var detection: Detection
@export var other_areas: Array[Area2D]



func _ready() -> void:
	_setup_physics_properties()
	
func set_bt_player_active(active: bool) -> void:
	if bt_player:
		bt_player.active = active

func set_rigid_physics_active(active: bool) -> void:
	if active:
		freeze = false
		set_bt_player_active(false)
	else:
		freeze = true
		set_bt_player_active(true)
