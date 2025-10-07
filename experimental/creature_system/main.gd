extends Node

@onready var world = $GameContainer/GameViewportContainer/GameViewport/World
@onready var score_display = $HUD/MarginContainer/HBoxContainer/LeftPanel/ScoreDisplay
@onready var terrain_manager = $GameContainer/GameViewportContainer/GameViewport/World/TerrainManager
var player: Creature

func _ready() -> void:
	world.add_to_group("world")
	world.y_sort_enabled = false
	# do start menu
	
	# initialize player and place him in a random good spot
	_initialize_creature_as_player(preload("res://nodes/entity/player.tscn").instantiate(), Vector2(-10, -10))
	
	# create world 3x3 chunks
	var chunk_locations: Array[Vector2i] = [Vector2i(0, 0), Vector2i(-0, -100), Vector2i(-100, 0), Vector2i(-100, -100)]
	
	for pos in chunk_locations:
		terrain_manager.create_chunk(pos)
	
	
	

func _initialize_creature_as_player(creature: Creature, pos: Vector2):
	creature.under_player_control = true
	creature.position = pos
	player = creature
	world.add_child(creature)

func _process(delta: float) -> void:
	if player:
		score_display.text = str(player.points)
