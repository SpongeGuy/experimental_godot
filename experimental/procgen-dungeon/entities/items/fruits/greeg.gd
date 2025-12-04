extends Item
class_name Fruit

@export var stat_sheet: CreatureStats
var stats: CreatureStats

@export var satiate_amount: float = 70.0
@export_range(0, 1) var grow_plant_chance: float = 0.35
@export var plant_scene: PackedScene

var _spawned_time: float = 0.0
const DESPAWN_TIME: float = 60.0

func _ready() -> void:
	name = "Fruit"
	stats = stat_sheet.duplicate()
	
	_spawned_time = Time.get_ticks_msec() / 1000.0
	super._ready()
	
func _process(_delta: float) -> void:
	if Time.get_ticks_msec() / 1000.0 - _spawned_time > DESPAWN_TIME:
		try_grow_plant_and_die()
		
func try_grow_plant_and_die() -> void:
	if randf() < grow_plant_chance and plant_scene:
		var plant := plant_scene.instantiate()
		plant.global_position = global_position + Vector2(randf_range(-40, 40), randf_range(-40, 40))
		get_tree().current_scene.add_child(plant)
	queue_free()
	
func eat(by: Node = null) -> void:
	if by is Creature:
		EventBus.try_change_creature_hunger.emit(by, -satiate_amount)
	queue_free()
