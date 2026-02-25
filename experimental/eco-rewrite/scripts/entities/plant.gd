extends Node2D
class_name Plant

	




var growth_timer: float = 0.0
var growth_limit: float = 2.0

func _process(delta: float) -> void:
	pass
	## DEBUG ONLY
	#growth_timer += delta * randf_range(0, 1)
	#if growth_timer > growth_limit:
		#growth_timer = 0
		#if randf() < 0.2:
			#_try_grow()
		



