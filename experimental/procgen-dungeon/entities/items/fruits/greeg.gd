extends Item
class_name Fruit

@export var stat_sheet: CreatureStats
var stats: CreatureStats

@export var satiate_amount: float = 70.0

var _spawned_time: float = 0.0
const DESPAWN_TIME: float = 60.0

func _ready() -> void:
	name = "Fruit"
	stats = stat_sheet.duplicate()
	
	_spawned_time = Time.get_ticks_msec() / 1000.0
	super._ready()
	

func activate(master: Entity, direction: Vector2) -> bool:
	if master is Creature:
		EventBus.try_change_creature_hunger.emit(master, -satiate_amount)
		queue_free()
		return true
	return false
