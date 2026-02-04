extends Node
class_name InputComponent

@export var master_origin: Node2D
enum InputBehavior{IDLE, EATING, STORING, USING}
var input_behavior: InputBehavior

var facing_direction: Vector2 = Vector2.ZERO

var holding_interact: bool = false
var holding_use: bool = false
var holding_toss: bool = false

@export var allow_input: bool = true
var intended_move_direction: Vector2 = Vector2.ZERO

signal move_input(direction: Vector2)

func _process(delta: float) -> void:
	if not allow_input:
		return
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	if camera and master_origin:
		var canvas_transform = camera.get_canvas_transform()
		var mouse_viewport = viewport.get_mouse_position()
		var mouse_global = canvas_transform.affine_inverse() * mouse_viewport + Vector2(4, 4)
		facing_direction = (mouse_global - master_origin.global_position).normalized()
	
	intended_move_direction = get_input_vector()
	
	move_input.emit(intended_move_direction)
		
	
	handle_inputs(delta)

func _input(event):
	
	
	if event.is_action_pressed("interact"):
		holding_interact = true
	if event.is_action_released("interact"):
		holding_interact = false
	
	if event.is_action_pressed("use"):
		holding_use = true
	if event.is_action_released("use"):
		holding_use = false
		use_released.emit()
		
	if event.is_action_pressed("toss"):
		holding_toss = true
	if event.is_action_released("toss"):
		holding_toss = false
		
signal interact_held(delta: float)
signal interact_just_pressed

signal use_held(delta: float)
signal use_released

signal toss_held(delta: float)
signal toss_just_pressed

func get_input_vector() -> Vector2:
	if not allow_input:
		return Vector2.ZERO
	var player_intended_velocity: Vector2 = Input.get_vector("move_west", "move_east", "move_north", "move_south").normalized()
	return player_intended_velocity

func handle_inputs(delta: float) -> void:
	input_behavior = InputBehavior.IDLE
	
	if holding_interact:
		interact_held.emit(delta)
		input_behavior = InputBehavior.STORING
	
	if Input.is_action_just_pressed("interact"):
		interact_just_pressed.emit()
		
	if holding_use:
		use_held.emit(delta)
		input_behavior = InputBehavior.USING
		
	if Input.is_action_just_pressed("toss"):
		toss_just_pressed.emit()
		
	

