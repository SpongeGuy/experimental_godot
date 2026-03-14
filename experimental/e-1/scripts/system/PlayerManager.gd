extends Node
class_name PlayerManager

static var player: Entity

func _ready() -> void:
	EventBus.ready_to_spawn_player.connect(_spawn_player)

func _spawn_player(pos: Vector2) -> void:
	initialize_player_at(pos)
	EventBus.change_camera_target.emit(player)

func initialize_player_at(pos: Vector2) -> void:
	player = EntityManager.spawn_safely(&"focks", pos)
	EventBus.player_spawned.emit(player)
