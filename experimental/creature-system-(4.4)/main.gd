extends Node

@onready var world = $GameContainer/GameViewportContainer/GameViewport/World
@onready var score_display = $HUD/MarginContainer/HBoxContainer/LeftPanel/ScoreDisplay
var player: Creature

func _ready() -> void:
	world.add_to_group("world")
	_initialize_creature_as_player(preload("res://nodes/entity/player.tscn").instantiate())

func _initialize_creature_as_player(creature: Creature):
	creature.under_player_control = true
	player = creature
	world.add_child(creature)

func _process(delta: float) -> void:
	score_display.text = str(player.points)
