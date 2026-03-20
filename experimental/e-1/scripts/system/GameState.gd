extends Node

# -------------------------------------------
# autoload 
#
# -------------------------------------------


enum Status { LOADING, PLAYING, PAUSED, GAME_OVER }

var state: Status = Status.LOADING
var score_points: int = 0
var nutri_points: int = 0

var player: Entity
var anthurium: Entity

signal score_points_changed
signal nutri_points_changed

signal game_state_changed(status: Status)

func change_game_state(status: Status) -> void:
	state = status
	game_state_changed.emit(state)

func add_score_points(amount: int) -> void:
	score_points += amount
	score_points_changed.emit()

func add_nutri_points(amount: int) -> void:
	nutri_points += amount
	nutri_points_changed.emit()
