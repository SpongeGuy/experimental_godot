extends Node
class_name InputComponent

@export var master_origin: Node2D
enum InputBehavior{IDLE, EATING, STORING, USING}
var input_behavior: InputBehavior

var facing_direction: Vector2 = Vector2.ZERO

var holding_interact: bool = false
var holding_use: bool = false


func _process(delta: float) -> void:
	handle_inputs(delta)

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_pos: Vector2 = event.position
		facing_direction = (mouse_pos - master_origin.global_position).normalized()
	
	if event.is_action_pressed("interact"):
		holding_interact = true
	if event.is_action_released("interact"):
		holding_interact = false
	
	if event.is_action_pressed("use"):
		holding_use = true
	if event.is_action_released("use"):
		holding_use = false
		
signal interact_held(delta: float)
signal interact_just_pressed

signal use_held(delta: float)
signal use_just_pressed

func get_input_vector() -> Vector2:
	var player_intended_velocity: Vector2 = Input.get_vector("move_west", "move_east", "move_north", "move_south").normalized()
	return player_intended_velocity

func handle_inputs(delta: float) -> void:
	input_behavior = InputBehavior.IDLE
	
	if holding_interact:
		interact_held.emit()
		#_try_store_item(delta, total_velocity)
	
	if Input.is_action_just_pressed("interact"):
		interact_just_pressed.emit()
		#_try_pickup()
		#_try_grab_from_storage()
		
	if holding_use:
		use_held.emit()
		#_try_use_held_item(delta)
		
	if Input.is_action_just_pressed("toss"):
		use_just_pressed.emit()
		#_try_eject_item()
		
	

