extends RigidBody2D
class_name Entity

@export var abilities: Dictionary[String, Ability] = {
	"ability_p": null,
	"ability_t": null,
	"consume_ability": null,
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

@export var physics_box: CollisionShape2D
@export var bt_player: BTPlayer

var is_held: bool = false

func set_held_state(held: bool, holder: Entity = null) -> void:
	is_held = held
	if held:
		set_rigid_physics_active(true)
		physics_box.disabled = true
		if bt_player:
			bt_player.active = false
		if holder:
			reparent(holder)
	else:
		set_rigid_physics_active(false)
		physics_box.disabled = false
		if bt_player:
			bt_player.active = true
		reparent(get_tree().current_scene)



@export_group("Areas")
@export var hitbox: Hitbox
@export var hurtbox: Hurtbox
@export var detection: Detection
@export var other_areas: Array[Area2D]



func _ready() -> void:
	_setup_physics_properties()

func set_rigid_physics_active(active: bool) -> void:
	if active:
		freeze = false
		if bt_player:
			bt_player.active = false
	else:
		freeze = true
		if bt_player:
			bt_player.active = true
