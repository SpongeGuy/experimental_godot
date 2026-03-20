extends Node

# -------------------------------------------
# autoload 
#
# -------------------------------------------


enum Status { LOADING, PLAYING, PAUSED, GAME_OVER }

var state: Status = Status.LOADING
var game_score: int = 0
var nutri_score: int = 0

var player: Entity
var anthurium: Entity

signal game_state_changed(status: Status)

func change_game_state(status: Status) -> void:
	state = status
	game_state_changed.emit(state)

func _ready() -> void:
	EventBus.added_game_score_to.connect(_check_if_game_score_player)
	EventBus.added_nutri_score_to.connect(_check_if_nutri_score_player)
	
func _check_if_game_score_player(subject: Entity, amount: int, source: Entity) -> void:
	if subject == player:
		game_score += amount
	
func _check_if_nutri_score_player(subject: Entity, amount: int, source: Entity) -> void:
	if subject == player:
		nutri_score += amount
	HUDParticleController.collect(source.global_position, UIHUD.score_collect_pos, floor(amount / 10), Color.LAWN_GREEN)
