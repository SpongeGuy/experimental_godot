extends Area2D
class_name Hurtbox

@export var damage: float
@export var constant_hurtbox: bool = false
@export var collision_shape: CollisionShape2D

var tween: Tween

func _ready() -> void:
	collision_layer = 1 << 9 # this is a hurtbox
	collision_mask = 1 << 8 # look for hitboxes (probably unnecessary)
	if not constant_hurtbox:
		collision_shape.disabled = true
	else:
		collision_shape.disabled = false

func activate_in_time_range(value: float, min: float, max: float) -> void:
	if value > min and value < max:
		collision_shape.disabled = false
	else:
		collision_shape.disabled = true

func activate(start: float, end: float) -> Signal:
	if tween: 
		tween.kill()
	collision_shape.disabled = true
	tween = create_tween()
	tween.tween_callback(func(): collision_shape.disabled = false).set_delay(start)
	tween.tween_callback(func(): collision_shape.disabled = true).set_delay(end - start)
	return tween.finished
