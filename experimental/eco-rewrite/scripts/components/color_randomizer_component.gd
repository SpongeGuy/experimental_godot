extends Node
class_name ColorRandomizerComponent


@export var sprite: Sprite2D
@export var gradient: Image
	
var image: Image

func _ready() -> void:
	var size: Vector2i = gradient.get_size()
	if size.x != size.y:
		return
	var random: Vector2i = Vector2i(randi_range(0, size.x), randi_range(0, size.y))
	var color: Color = gradient.get_pixelv(random)
	sprite.modulate = color
