extends Node2D
class_name Plant

@export var progression: int = 0
@onready var sprite: Sprite2D = $Sprite2D

@onready var search_radius: Area2D = $SearchRadius
@onready var search_radius_shape: CollisionShape2D = $SearchRadius/CollisionShape2D

var health: float
var nutrition: float = 0

var sprites: Array = [
	["res://assets/textures/sprites/environment/plants/forest/grass.png", "res://assets/textures/sprites/environment/plants/forest/grass1.png"],
	["res://assets/textures/sprites/environment/plants/forest/shrub.png", "res://assets/textures/sprites/environment/plants/forest/shrub1.png", "res://assets/textures/sprites/environment/plants/forest/shrub2.png", "res://assets/textures/sprites/environment/plants/forest/shrub3.png"],
	["res://assets/textures/sprites/environment/plants/forest/fern.png", "res://assets/textures/sprites/environment/plants/forest/fern1.png", "res://assets/textures/sprites/environment/plants/forest/fern2.png"],
	["res://assets/textures/sprites/environment/plants/forest/bush.png", "res://assets/textures/sprites/environment/plants/forest/bush1.png", "res://assets/textures/sprites/environment/plants/forest/bush2.png"],
	["res://assets/textures/sprites/environment/plants/forest/sapling.png", "res://assets/textures/sprites/environment/plants/forest/sapling1.png"],
	["res://assets/textures/sprites/environment/plants/forest/tree.png"]
]

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

func _try_grow(progress: int = 1) -> void:
	# try plant growth upgrade
	# fails if the next plant level is under required cell nutrition value
	if (progress + progression) >= sprites.size():
		return
	var cell: Cell = WorldManager.get_cell(position)
	if cell.nutrition < required_nutrition[progression + progress]:
		return
	_grow(progress)
	

func _grow(progress: int = 1) -> void:
	
	progression += progress
	
	var possible_texture_paths = sprites[progression]
	var texture_index: int = randi_range(0, possible_texture_paths.size() - 1)
	var texture: Texture2D = load(possible_texture_paths[texture_index])
	
	sprite.texture = texture
	sprite.centered = false
	
	sprite.position.y = -sprite.texture.get_height()
	sprite.position.x = -sprite.texture.get_width() / 2.0
	
	health += health_values[progression]
	var radius: float = area_radii[progression]
	search_radius_shape.shape.radius = radius
	
	nutrition += required_nutrition[progression]


var growth_timer: float = 0.0
var growth_limit: float = 2.0

var nearby_timer: float = randf()
var nearby_limit: float = 0.1
func _process(delta: float) -> void:
	nearby_timer += delta
	if nearby_timer > nearby_limit:
		nearby_timer = 0
		var nearby: Array = get_nearby_plants()
		var max_nearby_progression: int = 0
		for plant in nearby:
			if randf() < 0.2:
				plant.take_damage(1 * (progression + 1))
			
	# DEBUG ONLY
	growth_timer += delta * randf_range(0, 1)
	if growth_timer > growth_limit:
		growth_timer = 0
		if randf() < 0.2:
			_try_grow()
		
	
func get_nearby_plants() -> Array:
	# get all nearby plants except for self
	
	var plant_areas: Array = search_radius.get_overlapping_areas()
	var plants: Array[Plant]
	var id: int
	for i in range(plant_areas.size()):
		if plant_areas[i] == self:
			id = i
	
	if plant_areas.size() > 0:
		plant_areas.remove_at(id)
		
	for area in plant_areas:
		var parent = area.get_parent()
		if parent is Plant:
			plants.append(parent)
	return plants

func try_growth() -> void:
	pass

func die() -> void:
	queue_free()

func take_damage(value: float) -> void:
	health -= value
	if health <= 0.0:
		die()
