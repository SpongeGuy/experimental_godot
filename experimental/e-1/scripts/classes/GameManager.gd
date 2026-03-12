extends Node
class_name GameManager


static var _entity_container: Node2D
static var player: CharacterBody2D
static var time: float = 0.0

@export var camera_controller: CameraController
@export var ysort: Node2D
@export var world: Node2D

func _ready() -> void:
	if ysort:
		_entity_container = ysort

func _process(delta: float) -> void:
	time += delta
	
func _physics_process(delta: float) -> void:
	camera_controller.go_to(player.global_position, delta)

static func get_entity_container():
	if _entity_container:
		return _entity_container
	return null

static func add_entity(e: Entity) -> void:
	_entity_container.add_child(e)

static func register_player(body: CharacterBody2D) -> void:
	player = body
