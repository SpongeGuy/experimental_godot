extends Node3D

@onready var lil_cube: MeshInstance3D = $Planet/medium
@onready var even_lil_cube: MeshInstance3D = $Planet/small
@onready var skybox: MeshInstance3D = $Planet/skybox
@onready var audio_streamer: AudioStreamPlayer = $MenuMusic
@onready var camera: Camera3D = $Camera3D

@onready var ui_vbox: VBoxContainer =  $Control/MenuOptions
@onready var ui_play_button: Button = $Control/MenuOptions/PlayButton/Button


@export var animation_rot_y: Curve
@export var camera_rotation_delta: Curve

var elapsed_time: float = 0
var camera_animating: bool = true
var camera_target_rotation_degrees: Vector3

func get_sin_in_range(a: float, b: float, offset: float = 0, multiplier: float = 1):
	return a+(b-a) * ((sin(multiplier * elapsed_time + offset)+1) / 2)

@onready var animator = $AnimationPlayer

func planet_animation(delta: float, start_time: float = 0) -> void:
	if elapsed_time - start_time <= animation_rot_y.max_domain:
		print(elapsed_time - start_time, " ", animation_rot_y.max_domain)
		lil_cube.rotation.y = animation_rot_y.sample(elapsed_time - start_time)
		lil_cube.rotation.z = animation_rot_y.sample(elapsed_time - start_time)  / 3
		lil_cube.rotation.x = animation_rot_y.sample(elapsed_time - start_time)  / 5
	else:
		var p2: Vector2 = animation_rot_y.get_point_position(animation_rot_y.get_point_count() - 1)
		var p1: Vector2 = animation_rot_y.get_point_position(animation_rot_y.get_point_count() - 2)
		var slope = (p2.y - p1.y) / (p2.x - p1.x)
		lil_cube.rotation.y += slope * delta
		lil_cube.rotation.z += slope/3 * delta
		lil_cube.rotation.z += slope/5 * delta
		lil_cube.position.y += sin(elapsed_time - start_time + PI/4) * delta * 0.1
	
	
	
func orbiter_animation(delta: float, start_time: float = 0) -> void:
	even_lil_cube.position.x = lil_cube.position.x + get_sin_in_range(-0.3, 0.3, PI/5, 2)
	even_lil_cube.position.y = lil_cube.position.y + get_sin_in_range(-0.3, 0.3, PI/3, 2)
	even_lil_cube.position.z = get_sin_in_range(-2.1, -1.4, 0, 2)
	
func skybox_animation(delta: float) -> void:
	skybox.rotation.y += 1 * delta
	
func camera_animation(delta: float) -> void:
	if camera_animating and elapsed_time < camera_rotation_delta.max_domain:
		camera.rotation.x += camera_rotation_delta.sample(elapsed_time) * delta
	elif camera_animating:
		camera.rotation = lerp(camera.rotation, Vector3(0, 0, 0), delta)
	else:
		camera.rotation_degrees = lerp(camera.rotation_degrees, camera_target_rotation_degrees, delta)
	
func _ready() -> void:
	audio_streamer.playing = true
	camera.rotation_degrees = Vector3(90, 0, 0)
	
	# the damn arrow next to each menu option
	# needs to be connected to the focus callbacks
	for hbox in ui_vbox.get_children():
		if hbox is HBoxContainer:
			var button = hbox.get_node("Button")
			var indicator = hbox.get_node("Label")
			
			indicator.text = ""
			
			button.focus_entered.connect(_on_button_focus_entered.bind(indicator))
			button.focus_exited.connect(_on_button_focus_exited.bind(indicator))
	
	ui_play_button.grab_focus()
	
func _on_button_focus_entered(indicator: Label):
	indicator.text = ">"
	
func _on_button_focus_exited(indicator: Label):
	indicator.text = " "


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	camera_animation(delta)
	planet_animation(delta, camera_rotation_delta.max_domain)
	orbiter_animation(delta, camera_rotation_delta.max_domain)
	skybox_animation(delta)
	elapsed_time += delta


func _on_options_button_pressed() -> void:
	camera_animating = false
	camera_target_rotation_degrees = Vector3(0, -90, 90)


func _on_play_button_pressed() -> void:
	camera_animating = false
	camera_target_rotation_degrees = Vector3(-90, 0, 0)
