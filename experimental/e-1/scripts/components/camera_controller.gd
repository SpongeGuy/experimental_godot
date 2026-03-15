extends Component
class_name CameraController

@export var lerp_weight: float = 1.0
var camera: Camera2D

static var target: Node2D
static var behavior: Behavior = Behavior.TRACKING

enum Behavior{ TRACKING, FROZEN }



func _ready() -> void:
	EventBus.camera_ready.connect(_on_camera_ready)

func _process(delta: float) -> void:
	if not target:
		return
	match behavior:
		Behavior.TRACKING:
			go_to(target.global_position, delta)
			

func _on_camera_ready(c: Camera2D) -> void:
	camera = c


static func change_camera_target(new_target: Node2D) -> void:
	target = new_target
	EventBus.camera_target_changed.emit(target)

func go_to(pos: Vector2, delta: float) -> void:
	camera.position = lerp(camera.position, pos, delta * lerp_weight)

func go_instantly_to(pos: Vector2) -> void:
	camera.position = pos
