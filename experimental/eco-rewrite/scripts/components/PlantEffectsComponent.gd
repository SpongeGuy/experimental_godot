extends Node
class_name PlantEffectsComponent

@export var sprite: Sprite2D

var sprites: Array = [
	["res://assets/textures/sprites/environment/plants/forest/grass.png", "res://assets/textures/sprites/environment/plants/forest/grass1.png"],
	["res://assets/textures/sprites/environment/plants/forest/shrub.png", "res://assets/textures/sprites/environment/plants/forest/shrub1.png", "res://assets/textures/sprites/environment/plants/forest/shrub2.png", "res://assets/textures/sprites/environment/plants/forest/shrub3.png"],
	["res://assets/textures/sprites/environment/plants/forest/fern.png", "res://assets/textures/sprites/environment/plants/forest/fern1.png", "res://assets/textures/sprites/environment/plants/forest/fern2.png"],
	["res://assets/textures/sprites/environment/plants/forest/bush.png", "res://assets/textures/sprites/environment/plants/forest/bush1.png", "res://assets/textures/sprites/environment/plants/forest/bush2.png"],
	["res://assets/textures/sprites/environment/plants/forest/sapling.png", "res://assets/textures/sprites/environment/plants/forest/sapling1.png"],
	["res://assets/textures/sprites/environment/plants/forest/tree.png"]
]

func update_sprite(progression: int) -> void:
	var possible_texture_paths = sprites[progression]
	var texture_index: int = randi_range(0, possible_texture_paths.size() - 1)
	var texture: Texture2D = load(possible_texture_paths[texture_index])
	
	sprite.texture = texture
	sprite.centered = false
	
	sprite.position.y = -sprite.texture.get_height()
	sprite.position.x = -sprite.texture.get_width() / 2.0
