extends Creature

@onready var hurt_player: AudioStreamPlayer2D = $Hurt
var hurt_sound: AudioStream = preload("res://assets/sounds/hurt_1.sfxr")
var hurt_sound_pitch: float = 1.0
@onready var polygon: Polygon2D = $Graphics/Polygon2D

@onready var debug_label: Label = $Label
var label_text = ""

func _process(delta: float) -> void:
	super._process(delta)

func _take_damage(amount: float, origin: Node2D):
	hurt_sound_pitch = remap(creature_stats.health, creature_stats.base_health, 0.0, 0.5, 1.6)
	hurt_player.pitch_scale = hurt_sound_pitch
	_play_sound(hurt_player, hurt_sound)
	super._take_damage(amount, origin)
