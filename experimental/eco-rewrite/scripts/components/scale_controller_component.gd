extends Node
class_name ScaleControllerComponent

@export var target: Node2D

func scale_down_to_zero_over_time(time: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(target, "scale", Vector2.ZERO, time)
	tween.finished.connect(func(): 
		target.hide()
		tween.kill()
		)

func scale_up_to_one_over_time(time: float) -> void:
	var tween = get_tree().create_tween()
	target.show()
	tween.tween_property(target, "scale", Vector2.ONE, time)
	tween.finished.connect(func(): tween.kill())
