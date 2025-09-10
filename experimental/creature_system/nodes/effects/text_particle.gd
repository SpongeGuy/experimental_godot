extends Node2D

var velocity: Vector2
var movement_speed: float = 50
@onready var label: Label = $Label
@onready var death_timer: Timer = $Timer

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _set_random_direction() -> void:
	var direction: Vector2 = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	velocity = direction * movement_speed

func create(text: String, pos: Vector2, direction = null):
	position = pos
	if direction:
		velocity = direction * movement_speed
	else:
		_set_random_direction()
	$Label.text = text
	
func _ready() -> void:
	death_timer.start()
	
func _process(delta: float) -> void:
	if death_timer.is_stopped():
		queue_free()
