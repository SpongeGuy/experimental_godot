extends RigidBody2D
class_name Fruit

@export var stat_sheet: CreatureStats
var stats: CreatureStats

@export var satiate_amount: float = 70.0
@export_range(0, 1) var grow_plant_chance: float = 0.35
@export var plant_scene: PackedScene

@export var bounce: float = 0.3
@export var friction: float = 1.0
@export var base_linear_damp: float = 6.0
@export var base_mass: float = 0.8

var _spawned_time: float = 0.0
const DESPAWN_TIME: float = 60.0

func _ready() -> void:
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = bounce
	physics_material_override.friction = friction

	linear_damp = base_linear_damp
	mass = base_mass
	gravity_scale = 0.0
	
	collision_layer = 1 << 4 # layer 5 = fruits
	collision_mask = (1 << 1) # terrain
	collision_mask |= (1 << 4) # other fruits
	collision_mask |= (1 << 2) # creatures collide and kick fruits around

	_spawned_time = Time.get_ticks_msec() / 1000.0
	
func _process(_delta: float) -> void:
	if Time.get_ticks_msec() / 1000.0 - _spawned_time > DESPAWN_TIME:
		try_grow_plant_and_die()
		
func try_grow_plant_and_die() -> void:
	if randf() < grow_plant_chance and plant_scene:
		var plant := plant_scene.instantiate()
		plant.global_position = global_position + Vector2(randf_range(-40, 40), randf_range(-40, 40))
		get_tree().current_scene.add_child(plant)
		print("tree ", plant)
	queue_free()
	
func eat(by: Node = null) -> void:
	if by is Creature:
		EventBus.try_change_creature_hunger.emit(by, -satiate_amount)
	queue_free()
