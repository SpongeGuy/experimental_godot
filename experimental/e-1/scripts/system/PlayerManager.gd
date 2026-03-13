extends Node
class_name PlayerManager

static var player: Entity
var player_scene: PackedScene = preload("res://scenes/creatures/pack_1/focks.tscn")

func initialize_player_at(pos: Vector2) -> void:
	var p = player_scene.instantiate()
	p.global_position = pos
	EntityManager.add_entity(p)
	player = p
	EventBus.player_spawned.emit(p)
