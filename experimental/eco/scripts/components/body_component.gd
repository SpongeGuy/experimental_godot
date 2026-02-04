extends Node
class_name BodyComponent

@export var main_sprite: Sprite2D
@export var movement_component: MovementComponent
var input_component: InputComponent
@export var hand_component: HandComponent

@export var hand_positions: Dictionary = {
	"idle": Vector2(3.0, 2.0),
	"move_left": Vector2(-5.0, 1.0),
	"move_right": Vector2(5.0, 1.0)
}

@export var mouth_positions: Dictionary = {
	"idle": Vector2(0.0, -5.0),
	"move_left": Vector2(-4.0, -5.0),
	"move_right": Vector2(4.0, -5.0)
}

func _ready() -> void:
	input_component = movement_component.input_component
	
func _physics_process(delta: float) -> void:
	update_sprite_facing()
	_update_cheek_size()

func update_sprite_facing() -> void:
	if abs(movement_component.total_velocity.x) < 0.1:
		# stopped
		main_sprite.frame_coords.x = 0
		if input_component.input_behavior == input_component.InputBehavior.EATING or input_component.input_behavior == input_component.InputBehavior.STORING:
			hand_component.held_item_position.position = lerp(hand_component.held_item_position.position, mouth_positions["idle"], 0.1)
		else:
			hand_component.held_item_position.position = lerp(hand_component.held_item_position.position, hand_positions["idle"], 0.1)
	else:
		# moving
		main_sprite.frame_coords.x = 1
		
		if movement_component.total_velocity.x < 0:
			# moving left
			main_sprite.scale.x = -1
			if input_component.input_behavior == input_component.InputBehavior.EATING or input_component.input_behavior == input_component.InputBehavior.STORING:
				hand_component.held_item_position.position = lerp(hand_component.held_item_position.position, mouth_positions["move_left"], 0.1)
			else:
				hand_component.held_item_position.position = lerp(hand_component.held_item_position.position, hand_positions["move_left"], 0.5)
			
		elif movement_component.total_velocity.x > 0:
			# moving right
			main_sprite.scale.x = 1
			if input_component.input_behavior == input_component.InputBehavior.EATING or input_component.input_behavior == input_component.InputBehavior.STORING:
				hand_component.held_item_position.position = lerp(hand_component.held_item_position.position, mouth_positions["move_right"], 0.1)
			else:
				hand_component.held_item_position.position = lerp(hand_component.held_item_position.position, hand_positions["move_right"], 0.5)


func _update_cheek_size(delta: float) -> void:
	var inventory_capacity_ratio: float = float(inventory.storage.size()) / float(inventory.max_capacity)
	if inventory_capacity_ratio > 0.8:
		main_sprite.frame_coords.y = 2
	elif inventory_capacity_ratio > 0.5:
		main_sprite.frame_coords.y = 1
	else:
		main_sprite.frame_coords.y = 0
