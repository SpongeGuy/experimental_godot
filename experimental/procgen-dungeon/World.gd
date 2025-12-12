extends Node2D
class_name World

@onready var tilemap_layer: TileMapLayer = $Terrain
@onready var entities: Node2D = $Entities

func _ready() -> void:
	WorldManager.tilemap_layers["base"] = tilemap_layer
	EventBus.entity_spawned.connect(_do_spawn_animation)
	EventBus.creature_died.connect(_decrement_amount_of_creatures)
	
	generate_some_terrain()
	_spawn_new_player(Vector2(150, 150))
	WaveSpawnManager.entity_container = entities
	start_next_wave()
	
var amount_of_creatures: int = 0

var current_wave: int = 0

func start_next_wave() -> void:
	current_wave += 1
	WaveSpawnManager.start_wave(current_wave)
			
func _decrement_amount_of_creatures(creature: Creature, killer: Node2D) -> void:
	amount_of_creatures -= 1
	print(amount_of_creatures)
	if amount_of_creatures <= 4:
		start_next_wave()
	
func _spawn_new_player(position: Vector2) -> void:
	var scene: PackedScene = preload("res://entities/creatures/herbivores/grunt/grunt.tscn")
	var player: Creature = scene.instantiate()
	player.abilities["ability_p"] = AbilityPickUp.new()
	player.abilities["ability_t"] = AbilityToss.new()
	player.abilities["ability_u"] = AbilityUse.new()
	player.accept_player_input = true
	var player_debug_controller = PlayerDebug.new()
	player_debug_controller.master = player
	entities.add_child(player)
	player.add_child(player_debug_controller)
	WorldManager.spawn_cell_rect(WorldManager.world_to_cell(player.position - Vector2(32, 32), tilemap_layer), 5, 5, Cell.CellType.GROUND, tilemap_layer)
	
func _do_spawn_animation(position: Vector2, entity: Entity) -> void:
	var scene = preload("res://assets/animations/spawn_animation.tscn")
	var spawn_animation: SpawnAnimation = scene.instantiate()
	entity.add_child(spawn_animation)
	if entity is Creature and entity.accept_player_input:
		spawn_animation.spawn_animation.play("spawn_player")
	else:
		spawn_animation.spawn_animation.play("spawn")
	
	
	spawn_animation.spawn_animation.animation_finished.connect(
		func(_anim_name: String):
			spawn_animation.queue_free()
	)
	
	amount_of_creatures += 1
	
func generate_some_terrain() -> void:
	for x in range (-3, 3):
		for y in range(-2, 2):
			WorldManager.generate_debug_chunk_at_global(Vector2i(x, y), tilemap_layer)
	var times: int = 3
	for i in range(times):
		var position: Vector2 = Vector2(randi_range(0, 25), randi_range(0, 25))
		WorldManager.generate_blob_chain(position, randf_range(0, 360), 30, 75, 5, 50, 0.2, 0.3, Cell.CellType.SOFT_WALL, tilemap_layer)
		
	WorldManager.spawn_irregular_blob(Vector2(randf_range(0, 250), randf_range(0, 150)), 150, Cell.CellType.SOFT_WALL, tilemap_layer)
	
	
