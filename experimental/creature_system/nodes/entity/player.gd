extends Creature

@onready var mouse_target: Node2D = $MousePosition

func _process(delta: float) -> void:
	mouse_target.position = get_global_mouse_position()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		attack.activate(mouse_target)

func _physics_process(delta: float) -> void:
	var input_direction = Input.get_vector("left_input", "right_input", "up_input", "down_input")
	if input_direction.length() >= 1:
		input_direction = input_direction.normalized()
		
	velocity = input_direction * creature_stats.movement_speed * delta
	move_and_slide()

	rotation = atan2(get_global_mouse_position().y - global_position.y, get_global_mouse_position().x - global_position.x)
	

