extends Component
class_name CameraController

@export var lerp_weight: float = 1.0
@export var camera: Camera2D

var player: CharacterBody2D
	
func go_to(target_position: Vector2, delta: float) -> void:
	camera.position = lerp(camera.position, target_position, delta * lerp_weight)
