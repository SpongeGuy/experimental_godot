extends Node
class_name PlayerManager

static var player: Entity


func spawn_player(pos: Vector2) -> void:
	player = EntityManager.spawn_safely(&"focks", pos)
	EventBus.player_spawned.emit(player)
	CameraController.change_camera_target(player)

