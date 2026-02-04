extends Node
class_name HandEffectsComponent

@export var hand_component: HandComponent
@export var shake_intensity: float
@export var input_component: InputComponent
@export var hand_movement_factor: float = 10

@export var hand_positions: Dictionary = {
	Direction.IDLE: Vector2(2.0, 2.0),
	Direction.WEST: Vector2(-5.0, 1.0),
	Direction.EAST: Vector2(6.0, 1.0)
}

@export var mouth_positions: Dictionary = {
	Direction.IDLE: Vector2(0.0, -5.0),
	Direction.WEST: Vector2(-4.0, -5.0),
	Direction.EAST: Vector2(4.0, -5.0)
}

@export var toss_sound: AudioStream
@export var pick_up_sound: AudioStream
@export var take_from_storage_sound: AudioStream

enum Direction{IDLE, NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST}
var hand_position: Direction = Direction.IDLE

func _shake_item(item: RigidBody2D) -> void:
	item.position = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))

func _update_hand_position(intended_velocity: Vector2, total_velocity: Vector2) -> void:
	if abs(total_velocity.x) < 0.2:
		hand_position = Direction.IDLE
	elif total_velocity.x < 0:
		hand_position = Direction.WEST
	elif total_velocity.x > 0:
		hand_position = Direction.EAST
	
func _move_hand(delta: float) -> void:
	match input_component.input_behavior:
		input_component.InputBehavior.IDLE:
			hand_component.hand.position = lerp(hand_component.hand.position, hand_positions[hand_position], delta * hand_movement_factor)
		input_component.InputBehavior.EATING:
			hand_component.hand.position = lerp(hand_component.hand.position, mouth_positions[hand_position], delta * hand_movement_factor)
		input_component.InputBehavior.USING:
			hand_component.hand.position = lerp(hand_component.hand.position, mouth_positions[hand_position], delta * hand_movement_factor)
		input_component.InputBehavior.STORING:
			hand_component.hand.position = lerp(hand_component.hand.position, mouth_positions[hand_position], delta * hand_movement_factor)
	
func _process(delta: float) -> void:
	_move_hand(delta)



func _on_hand_component_item_picked_up(item: RigidBody2D) -> void:
	AudioManager.play_sound_at_position(pick_up_sound, hand_component.master_origin.global_position)


func _on_hand_component_item_taken_from_storage(item: RigidBody2D) -> void:
	AudioManager.play_sound_at_position(take_from_storage_sound, hand_component.master_origin.global_position)


func _on_hand_component_item_tossed(item: RigidBody2D) -> void:
	AudioManager.play_sound_with_random_pitch(toss_sound, hand_component.master_origin.global_position, 0.8, 1.2)
