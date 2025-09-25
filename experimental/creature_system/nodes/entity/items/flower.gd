class_name Flower extends Item

@export var value: int = 1
@onready var sprite = $Sprite2D
var pickup_sound: AudioStream = preload("res://assets/sounds/pickup_flower.sfxr")

func _ready() -> void:
	super._ready()
	is_carryable = false
	sprite.frame = randi_range(0, 7)

func _activate(creature: Creature) -> void:
	creature.points += value
	var random_pitch = randf_range(0.8, 1.2)
	AudioManager.play_sound(pickup_sound, position, {"pitch_scale": random_pitch, "volume_db": -6.0})
	
