extends Area2D
class_name Hurtbox

@export var damage: float
@export var constant_hurtbox: bool = false
@export var collision_shape: CollisionShape2D

var tween: Tween

signal activated

func _ready() -> void:
	collision_layer = 1 << 7 # this is a hurtbox
	if not constant_hurtbox:
		collision_shape.disabled = true
	else:
		collision_shape.disabled = false
		
func set_active(value: bool) -> void:
	collision_shape.disabled = !value

func activate_in_time_range(value: float, min: float, max: float) -> void:
	if value > min and value < max:
		collision_shape.disabled = false
	else:
		collision_shape.disabled = true

func activate(start: float, end: float) -> Signal:
	if tween: 
		tween.kill()
	collision_shape.disabled = true
	activated.emit()
	tween = create_tween()
	tween.tween_callback(func(): collision_shape.disabled = false).set_delay(start)
	tween.tween_callback(func(): collision_shape.disabled = true).set_delay(end - start)
	return tween.finished
