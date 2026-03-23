extends Component
class_name InputComponent

# -------------------------------------------------------------
# checks every frame for certain user inputs.
# ------------------------------------------------------------

@export var label1: Label
@export var label2: Label
@export var label3: Label
@export var label4: Label

var move_input_direction: Vector2

var just_pressed: Array[bool] = [false, false, false, false]
var hold_time: Array[float] = [0.0, 0.0, 0.0, 0.0]
var is_held: Array[bool] = [false, false, false, false]
var just_released: Array[bool] = [false, false, false, false]

signal input_just_pressed(id: int)
signal input_just_released(id: int, held_time: float)

func _process(delta: float) -> void:
	_handle_action(delta, 0, "primary_action")
	_handle_action(delta, 1, "secondary_action")
	#_handle_action(delta, 2, "ternary_action")
	#_handle_action(delta, 3, "quaternary_action")
	move_input_direction = Input.get_vector("west", "east", "north", "south")
	label1.text = str(just_pressed)
	var str_hold_time: Array[float] = [
		snapped(hold_time[0], 0.01),
		snapped(hold_time[1], 0.01),
		snapped(hold_time[2], 0.01),
		snapped(hold_time[3], 0.01)
	]
	label2.text = str(str_hold_time)
	label3.text = str(is_held)
	label4.text = str(just_released)
	
func _handle_action(delta: float, id: int, action: String) -> void:
	just_pressed[id] = Input.is_action_just_pressed(action)
	if just_pressed[id]:
		input_just_pressed.emit(id)
		
	just_released[id] = Input.is_action_just_released(action)
	if just_released[id]:
		input_just_released.emit(id, hold_time[id])
		
	is_held[id] = Input.is_action_pressed(action)
	if is_held[id]:
		hold_time[id] += delta
	else:
		hold_time[id] = 0
	
	
	
	
