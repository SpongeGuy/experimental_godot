extends Component
class_name PointsInterface

@export var score_points: int = 0
@export var nutri_points: int = 0

func add_score_points(amount: int) -> void:
	score_points += amount
	if GameState.player == entity:
		GameState.add_score_points(amount)

func add_nutri_points(amount: int) -> void:
	nutri_points += amount
	if GameState.player == entity:
		GameState.add_nutri_points(amount)
