extends Node
class_name PlantComponent

@export var progression: int = 0
var current_progression: int = 0
@export var max_progression: int = 5
@export var master_origin: Node2D
@export var health_component: HealthComponent
@export var nutrition_component: NutritionComponent
@export var eye_component: EyeComponent

signal grew(progression: int)

var area_radii: Array[float] = [
	2,
	3,
	4,
	5,
	8.0,
	20.0,
]

var health_values: Array[float] = [
	1,
	5,
	10,
	25,
	55,
	220
]

var required_nutrition: Array[float] = [
	5,
	15,
	30,
	45,
	60,
	75, 
]

func _ready() -> void:
	_grow(0)
	for i in range(1, progression):
		_grow()
			
func _process(delta: float) -> void:
	check_nearby_plants_and_rot(delta)
			
var nearby_timer: float = 0.0
var nearby_timer_limit: float = 0.1

func check_nearby_plants_and_rot(delta: float) -> void:
	nearby_timer += delta
	if nearby_timer > nearby_timer_limit:
		nearby_timer = 0
		var nearby: Array = eye_component.nearby_plants
		var max_nearby_progression: int = 0
		for plant in nearby:
			var other_hp: HealthComponent = plant.get_node_or_null("HealthComponent")
			if randf() < 0.1:
				if other_hp:
					other_hp.take_damage(1 * (current_progression + 1), master_origin)
			
			
func _try_grow(progress: int = 1) -> void:
	# try plant growth upgrade
	# fails if the next plant level is under required cell nutrition value
	if (progress + current_progression) >= max_progression:
		return
	var cell: Cell = WorldManager.get_cell(master_origin.position)
	if cell.nutrition < required_nutrition[current_progression + progress]:
		return
	_grow(progress)

func _grow(progress: int = 1) -> void:
	current_progression += progress
	
	grew.emit(current_progression)
	
	health_component.health += health_values[current_progression]
	var radius: float = area_radii[current_progression]
	eye_component.sight_area_shape.shape.radius = radius
	
	nutrition_component.nutrition += required_nutrition[current_progression]
