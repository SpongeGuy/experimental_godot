extends Component
class_name SoundPlayer

@export var possible_sounds: Array[AudioStream]
@export var visibility: VisibilityComponent

@export var pitch_min: float = 1.0
@export var pitch_max: float = 1.0
@export var volume_db: float = 0.0

func play_sound() -> void:
	if visibility and visibility._visible == false:
		return
	var sound: AudioStream = possible_sounds.pick_random()
	AudioManager.play_sound_with_random_pitch(sound, entity.global_position, pitch_min, pitch_max, volume_db)

func play_sound_with_negative_volume_modifier(modifier: float) -> void:
	if visibility and visibility._visible == false:
		return
	var db: float = -14
	var sound: AudioStream = possible_sounds.pick_random()
	AudioManager.play_sound_with_random_pitch(sound, entity.global_position, pitch_min, pitch_max, volume_db + (db * modifier))
