extends Component
class_name CameraController

@export var lerp_weight: float = 1.0
@export var camera: Camera2D
@export var game_manager: GameManager

var player: CharacterBody2D

func get_player() -> void:
	player = game_manager.player

func follow_player(delta: float) -> void:
	if not player:
		get_player()
		return
	go_to(player.global_position, delta)
	
func go_to(target_position: Vector2, delta: float) -> void:
	camera.position = lerp(camera.position, target_position, delta * lerp_weight)

func _physics_process(delta: float) -> void:
	follow_player(delta)
