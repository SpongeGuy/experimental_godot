extends Component
class_name InputComponent

# -------------------------------------------------------------
# checks every frame for certain user inputs.
# ------------------------------------------------------------
@export var primary_ability: Ability
@export var secondary_ability: Ability

@export var label1: Label
@export var label2: Label
@export var label3: Label
@export var label4: Label

var primary_just_pressed: bool = false
var secondary_just_pressed: bool = false

var primary_hold_time: float = 0
var primary_is_held: bool = false

var secondary_hold_time: float = 0
var secondary_is_held: bool = true

var move_input_direction: Vector2

func _process(delta: float) -> void:
	primary_just_pressed = Input.is_action_just_pressed("primary_action")
	if primary_just_pressed:
		primary_ability.execute()
	secondary_just_pressed = Input.is_action_just_pressed("secondary_action")
	
	label1.text = str(primary_just_pressed)
	label2.text = str(secondary_just_pressed)
	
	primary_is_held = Input.is_action_pressed("primary_action")
	if primary_is_held:
		primary_hold_time += delta
	else:
		primary_hold_time = 0
		
	secondary_is_held = Input.is_action_pressed("secondary_action")
	if secondary_is_held:
		secondary_hold_time += delta
	else:
		secondary_hold_time = 0
	
	label3.text = str(snapped(primary_hold_time, 0.01))
	
	move_input_direction = Input.get_vector("west", "east", "north", "south")
	
	label4.text = str(move_input_direction)
