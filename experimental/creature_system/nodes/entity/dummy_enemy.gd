extends Creature

@onready var hurt_sound: AudioStreamPlayer2D = $Sounds/Hurt
@onready var test: AudioStreamPlayer2D = $Sounds/SfxrStreamPlayer2D

func _ready() -> void:
	test.sample_rate = 50.0

func _take_damage(amount: float):
	super._take_damage(amount)
	random()

func random():
	test.random_preset()
	test.build_sfx(true)
