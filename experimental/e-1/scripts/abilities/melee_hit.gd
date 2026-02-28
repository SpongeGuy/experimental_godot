extends Ability
class_name AbilityMeleeHit

@export var hurtbox: Hurtbox
@export var active_start: float
@export var active_end: float

var tween: Tween

func execute() -> void:
	if tween: 
		tween.kill()
	hurtbox.collision_shape.disabled = true
	tween = hurtbox.create_tween()
	tween.tween_callback(func(): hurtbox.collision_shape.disabled = false).set_delay(active_start)
	tween.tween_callback(func(): hurtbox.collision_shape.disabled = true).set_delay(active_end - active_start)
	tween.tween_callback(func(): finished.emit()).set_delay(active_end - active_start)
