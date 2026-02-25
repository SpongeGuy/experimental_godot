extends Creature


var facing_direction: Vector2 = Vector2.ZERO

enum MovementState {IDLE, MOVING, PHYSICS}

var movement_state = MovementState.IDLE

@export var inventory: InventoryStackComponent
@export var main_sprite: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	
	EntityManager.player_character = self
	
func _process(delta: float) -> void:
	_update_cheek_size()

func _update_cheek_size() -> void:
	var inventory_capacity_ratio: float = float(inventory.storage.size()) / float(inventory.max_capacity)
	if inventory_capacity_ratio > 0.8:
		main_sprite.frame_coords.y = 2
	elif inventory_capacity_ratio > 0.5:
		main_sprite.frame_coords.y = 1
	else:
		main_sprite.frame_coords.y = 0

@onready var cheek_component: CheekComponent = $CheekComponent

func _on_hand_component_toss_handled(handled: bool) -> void:
	if not handled:
		cheek_component._try_spit_item()
