extends Node
class_name TimeManager

enum DayState { DAWN, DAY, DUSK, NIGHT }
const DAYTIMES: Array[int] = [0, 5, 10, 15]
var day_names: Array[String] = ["Dawn", "Day", "Dusk", "Fog"]

static var elapsed: float
var day_state: DayState = DayState.DAWN


func _process(delta: float) -> void:
	if GameState.state != GameState.Status.PLAYING:
		return
	_elapse(delta)
		
		
		
		

func change_day_state(state: DayState) -> void:
	day_state = state
	EventBus.day_state_changed.emit(state, day_names[state])

func _elapse(delta: float) -> void:
	elapsed += delta

	# smart, emits only once when the time elapses enough to cause a change
	if day_state != DayState.NIGHT  and elapsed > DAYTIMES[day_state + 1]:
		change_day_state(day_state + 1)
