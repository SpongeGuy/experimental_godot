extends Node2D

@export var stomach_icon: Sprite2D
@export var hunger_component: HungerComponent

var origin: Vector2

func _ready() -> void:
	origin = position

func _process(delta: float) -> void:
	update_hunger_icon(delta)

var stomach_visibility_timer: float = 0
var stomach_visibility_timer_length: float = 4.5
var last_stomach_frame: int = 0

func show_hunger_icon(amount: float) -> void:
	stomach_visibility_timer = stomach_visibility_timer_length
	stomach_icon.modulate = Color(1, 1, 1, 1)

func update_hunger_icon(delta: float) -> void:
	var stomach_frame: int = floor(hunger_component.hunger / 10)
	if stomach_visibility_timer > 0.0:
		stomach_visibility_timer -= delta
	stomach_frame = clamp(stomach_frame, 0, stomach_icon.hframes - 1)
	if stomach_frame != last_stomach_frame and stomach_frame >= 0.0:
		show_hunger_icon(0)
		last_stomach_frame = stomach_frame
		
	
	stomach_icon.frame = stomach_frame
	if stomach_frame <= 3:
		stomach_icon.position = Vector2(randf_range(-1, 1), randf_range(-1, 1))
		if stomach_visibility_timer <= 0.0:
			#stomach_icon.global_position = lerp(stomach_icon.global_position, Vector2(100, 100), delta * 5)
			stomach_icon.modulate = lerp(stomach_icon.modulate, Color(1, 1, 1, 0.3), delta * 5)
	else:
		if stomach_visibility_timer <= 0.0:
			#stomach_icon.global_position = lerp(stomach_icon.global_position, Vector2(100, 100), delta * 5)
			stomach_icon.modulate = lerp(stomach_icon.modulate, Color(1, 1, 1, 0.0), delta * 5)
