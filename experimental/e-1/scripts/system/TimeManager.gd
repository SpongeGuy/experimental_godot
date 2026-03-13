extends Node
class_name TimeManager

enum DayState { DAWN, DAY, DUSK, NIGHT }

static var elapsed: float
var day_state: DayState = DayState.DAWN

var elapsing: bool = false

func _elapse(delta: float) -> void:
	elapsed += delta

func _process(delta: float) -> void:
	if elapsing:
		_elapse(delta)
		
	if elapsed > 10.0:
		day_state = DayState.DAY
