extends Node2D
class_name World

@onready var tilemap_layer: TileMapLayer = $Terrain
@onready var entities: Node2D = $Entities
var camera: Camera2D

var wave_ongoing: bool = false

func _ready() -> void:
	WorldManager.tilemap_layers["base"] = tilemap_layer
	EventBus.entity_spawned.connect(_do_spawn_animation)
	EventBus.entity_spawned.connect(_increment_amount_of_creatures)
	EventBus.creature_died.connect(_decrement_amount_of_creatures)
	EventBus.wave_started.connect(_wave_started)
	EventBus.wave_completed.connect(_wave_completed)
	
	generate_some_terrain()
	
	CreepMaster.spawn_initial_creep(Vector2(randf_range(0, 450), randf_range(0, 250)), WorldManager.tilemap_layers["base"])
	_spawn_new_player(Vector2(350, 350))
	WaveSpawnManager.entity_container = entities
	start_next_wave()
	
var amount_of_creatures: int = 0

var current_wave: int = 0

func _wave_started(wave_number: int, total_points: int) -> void:
	wave_ongoing = true
	print("wave started")
	
func _wave_completed(wave_number: int) -> void:
	wave_ongoing = false
	print("wave complete")

func start_next_wave() -> void:
	current_wave += 1
	WaveSpawnManager.start_wave(current_wave)

func _increment_amount_of_creatures(position: Vector2, entity: Entity) -> void:
	if entity is Creature and not entity.accept_player_input:
		print("spawn: ", amount_of_creatures)
		amount_of_creatures += 1

func _decrement_amount_of_creatures(creature: Creature, killer: Node2D) -> void:
	amount_of_creatures -= 1
	if amount_of_creatures <= 4 and not wave_ongoing:
		start_next_wave()
		print('starting next wave')
	print("kill: ", amount_of_creatures)
	
func _spawn_new_player(position: Vector2) -> void:
	var scene: PackedScene = preload("res://entities/creatures/herbivores/grunt/grunt.tscn")
	var player: Creature = scene.instantiate()
	player.abilities["ability_p"] = AbilityPickUp.new()
	player.abilities["ability_t"] = AbilityToss.new()
	player.abilities["ability_u"] = AbilityUse.new()
	player.accept_player_input = true
	player.position = position
	var player_debug_controller = PlayerDebug.new()
	player_debug_controller.master = player
	entities.add_child(player)
	player.add_child(player_debug_controller)
	WorldManager.player = player
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
	
	
	
func generate_some_terrain() -> void:
	for x in range (0, 7):
		for y in range(0, 4):
			WorldManager.generate_debug_chunk_at_global(Vector2i(x, y), tilemap_layer, Cell.CellType.GROUND)
			
	
	var times: int = 3
	for i in range(times):
		var pos: Vector2 = Vector2(randi_range(0, 425), randi_range(0, 225))
		WorldManager.generate_blob_chain(pos, randf_range(0, 360), 30, 75, 5, 50, 0.2, 0.3, Cell.CellType.SOFT_WALL, tilemap_layer)
		
	WorldManager.spawn_irregular_blob(Vector2(randf_range(0, 250), randf_range(0, 150)), 150, Cell.CellType.SOFT_WALL, tilemap_layer)
	WorldManager.spawn_cell_border(Vector2i(-3, -3), 62, 38, Cell.CellType.HARD_WALL, 4, WorldManager.tilemap_layers["base"])
	
func create_camera() -> void:
	camera = Camera2D.new()
	camera.offset = Vector2(-16, 0)
	add_child(camera)
