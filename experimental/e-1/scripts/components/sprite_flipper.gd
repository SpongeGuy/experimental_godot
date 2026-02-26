extends Node
class_name SpriteFlipper

@export var facing: FacingComponent
@export var sprite: Sprite2D

func _ready() -> void:
	facing.changed_direction.connect(flip_sprite)
	
func flip_sprite(_old_direction: Vector2, new_direction: Vector2) -> void:
	if new_direction.x > 0:
		sprite.scale.x = 1.0
	else:
		sprite.scale.x = -1.0
