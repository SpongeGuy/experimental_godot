extends Creature

# grunt exclusive things go here, but it's the simplest enemy type so probably not

func _process(_delta: float) -> void:
	_debug_update_label()
	
func _debug_update_label() -> void:
	debug_label.text = str(floor(hunger))
