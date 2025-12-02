extends CharacterBody2D
class_name FruitPlant

@export var stat_sheet: CreatureStats
var stats: CreatureStats

@onready var sight_area: Area2D = $SightArea

@onready var bt_player: BTPlayer = $BTPlayer

var nearby_bodies: Array[Node2D] = []

func _ready() -> void:
	stats = stat_sheet.duplicate()
	assert(stats)
	
	bt_player.blackboard.set_var("sight_area", sight_area)
	collision_layer = 1 << 4 # layer 5 = fruit
	
	if sight_area:
		sight_area.collision_mask = (1 << 4) # only look at fruits and other trees
		sight_area.body_entered.connect(_on_enter_sight_area)
		sight_area.body_exited.connect(_on_exit_sight_area)


# for organizing nearby nodes
func _on_enter_sight_area(body: Node2D) -> void:
	if body != self:
		nearby_bodies.append(body)
	
func _on_exit_sight_area(body: Node2D) -> void:
	nearby_bodies.erase(body)
