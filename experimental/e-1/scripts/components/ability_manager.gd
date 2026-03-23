extends Component
class_name AbilityManager

# -----------------------------------------------
# interfaces with an inputcomponent to activate abilities
# -----------------------------------------------

@export var abilities: Array[Ability]

@export var input: InputComponent

func _ready() -> void:
	input.input_just_pressed.connect(_on_input_just_pressed)
	input.input_just_released.connect(_on_input_just_released)

func _on_input_just_pressed(id: int) -> void:
	abilities[id].on_pressed()

func _on_input_just_released(id: int, held_time: float) -> void:
	abilities[id].on_released(held_time)

func _process(delta: float) -> void:
	for i in range(input.is_held.size()):
		if input.is_held[i]:
			if i >= abilities.size():
				continue
			if abilities[i] == null:
				continue
			abilities[i].on_held(delta)

