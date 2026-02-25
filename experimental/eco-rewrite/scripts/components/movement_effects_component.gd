extends Node
class_name MovementEffectsComponent

@export var main_sprite: Sprite2D


enum Direction{NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST}



func update_sprite_facing(intended_velocity: Vector2, total_velocity: Vector2) -> void:
	if abs(total_velocity.x) < 0.1:
		main_sprite.frame_coords.x = 0
	elif main_sprite.hframes > 1:
		main_sprite.frame_coords.x = 1
		
	if total_velocity.x < 0:
		main_sprite.scale.x = -1
	elif total_velocity.x > 0:
		main_sprite.scale.x = 1

