extends Component
class_name AnthuriumGrassComponent

var growth: int = 0
@export var sprite: Sprite2D

var spritesheets: Array = [
	load("res://assets/textures/characters/plants/flower1.png"),
	load("res://assets/textures/characters/plants/flower2.png"),
	load('res://assets/textures/characters/plants/flower3.png')
]

func _ready() -> void:
	sprite.texture = spritesheets.pick_random()
	growth = randi_range(0, sprite.hframes - 1)
	sprite.frame = growth
