extends Creature

var hurt_sound: AudioStream = preload("res://assets/sounds/hurt_1.sfxr")
var hurt_sound_pitch: float = 1.0

@onready var debug_label: Label = $Label
var label_text = ""

func _process(delta: float) -> void:
	super._process(delta)

func _take_damage(amount: float, origin: Node2D):
	hurt_sound_pitch = remap(creature_stats.health, creature_stats.base_health, 0.0, 0.5, 1.6)
	AudioManager.play_sound(hurt_sound, position, {"pitch_scale": hurt_sound_pitch})
	super._take_damage(amount, origin)

