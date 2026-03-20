extends Node

# -----------------------------------------------------------
# orchestrates the game
# utilizes all system nodes
# -----------------------------------------------------------

@export var game_viewport: SubViewport
var weather_scene: PackedScene = load("res://scenes/systems/weather.tscn")
var tile_set: TileSet = load("res://assets/tilesets/prototype.tres")

@export var dungeon_generator: DungeonGenerator
@export var player_manager: PlayerManager
@export var anthurium_manager: AnthuriumManager

func _ready() -> void:
	call_deferred("initialize_game")
	

func initialize_game() -> void:
	EventBus.starting_new_game.emit()
	GameState.change_game_state(GameState.Status.LOADING)
	
	initialize_tree()
	WorldGrid.init_grid(64, 64)
	print("grid initialized")
	
	var cell: CellData = CellData.new()
	cell.terrain = CellData.TerrainType.GROUND
	WorldGrid.set_rectangle(Vector2i(0,0), Vector2i(80, 46), cell)
	#dungeon_generator.generate()
	
	
	var player_spawn: Vector2 = Vector2(512, 512)
	var anthurium_spawn: Vector2 = Vector2(512, 512)
	
	anthurium_manager.spawn_anthurium(anthurium_spawn)
	
	EntityManager.spawn_safely(&"roots", Vector2(450, 450))
	EntityManager.spawn_safely(&"plopp_orb", Vector2(550, 500))
	EntityManager.spawn_safely(&"pitcher", Vector2(500, 450))
	
	
	await get_tree().create_timer(1).timeout
	player_manager.spawn_player(player_spawn)
	GameState.change_game_state(GameState.Status.PLAYING)
	
	
	




func initialize_tree() -> void:
	var container: Node2D = Node2D.new()
	container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var camera: Camera2D = Camera2D.new()
	
	
	var world: Node2D = Node2D.new()
	var weather: WeatherComponent = weather_scene.instantiate() as WeatherComponent
	
	
	var world_renderer: WorldRenderer = WorldRenderer.new()
	world_renderer.tile_set = tile_set
	world_renderer.z_index = -10
	
	var ysort: Node2D = Node2D.new()
	ysort.y_sort_enabled = true
	
	
	var background: Polygon2D = Polygon2D.new()
	var background_shape: PackedVector2Array = PackedVector2Array([
		Vector2(-100000, -100000),
		Vector2(-100000, 100000),
		Vector2(100000, 100000),
		Vector2(100000, -100000)
	])
	background.polygon = background_shape
	background.color = Color(0, 0, 0, 1)
	background.z_index = -50
	
	world.add_child(world_renderer)
	world.add_child(weather)
	world.add_child(ysort)
	world.add_child(background)
	
	container.add_child(camera)
	container.add_child(world)
	
	game_viewport.add_child(container)
	print("the trees")
	
	EventBus.camera_ready.emit(camera)
	EventBus.weather_ready.emit(weather)
	EventBus.ysort_ready.emit(ysort)


