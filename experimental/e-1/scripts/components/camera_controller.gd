extends Component
class_name CameraController

@export var lerp_weight: float = 1.0
var camera: Camera2D

static var target: Node2D
static var behavior: Behavior = Behavior.TRACKING

enum Behavior{ TRACKING, FROZEN }

var coords: Vector2

func _ready() -> void:
	EventBus.camera_ready.connect(_on_camera_ready)

func _physics_process(delta: float) -> void:
	if not target:
		return
	match behavior:
		Behavior.TRACKING:
			go_to(target.global_position, delta)
			
	coords = get_viewport().get_mouse_position()
	coords += camera.position - Vector2(320, 180)
			
			
func _input(event: InputEvent) -> void:
	var cell: CellData = CellData.new()
	cell.terrain = CellData.TerrainType.GROUND
	if event is InputEventMouseButton:
		var c = WorldGrid.get_cell(WorldGrid.world_to_tile(coords)).terrain
		print(str(c))
		WorldGrid.set_circle(WorldGrid.world_to_tile(coords), 3, cell)

func _on_camera_ready(c: Camera2D) -> void:
	camera = c


static func change_camera_target(new_target: Node2D) -> void:
	target = new_target
	EventBus.camera_target_changed.emit(target)

func go_to(pos: Vector2, delta: float) -> void:
	camera.position = lerp(camera.position, pos, delta * lerp_weight)

func go_instantly_to(pos: Vector2) -> void:
	camera.position = pos
