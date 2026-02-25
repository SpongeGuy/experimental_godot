extends Node
class_name EntitySpawnerComponent

@export var entity_to_spawn: PackedScene
@export var master_origin: Node2D

func register_action_handlers(executor: IntentExecutor):
	executor.register_action("spawn_entity", _spawn)
	
func _behavior_spawn(delta: float, intent: Intent) -> void:
	_spawn()

func _spawn() -> void:
	var e = entity_to_spawn.instantiate()
	e.global_position = master_origin.global_position
	WorldManager.world.entity_container.add_child(e)
