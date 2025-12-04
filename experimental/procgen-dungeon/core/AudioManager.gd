# AudioManager.gd (AutoLoad singleton)
extends Node

@export var max_polyphony_per_player: int = 16
@export var player_count: int = 8        # usually 4–12 is more than enough
@export var default_max_distance: float = 600.0
@export var default_attenuation: float = 1.0

var players: Array[AudioStreamPlayer2D] = []

func _ready() -> void:
	for i in player_count:
		var player = AudioStreamPlayer2D.new()
		player.bus = "SFX"
		player.max_distance = default_max_distance
		player.attenuation = default_attenuation
		player.max_polyphony = max_polyphony_per_player
		add_child(player)
		players.append(player)
	
	print("AudioManager ready – %d players × %d polyphony = %d max voices" % 
		  [player_count, max_polyphony_per_player, player_count * max_polyphony_per_player])

func play_at_position(stream: AudioStream, position: Vector2, settings: Dictionary = {}) -> void:
	if not stream:
		return
	
	# Find first player that still has free voices (or reuse any)
	var chosen: AudioStreamPlayer2D = null
	for p in players:
		if p.get_playback_position() == 0 or not p.playing:  # rough free-check
			chosen = p
			break
	if not chosen:
		chosen = players[0]  # steal the oldest one if all busy
	
	chosen.global_position = position
	chosen.stream = stream
	
	# Apply one-time overrides
	if settings.has("volume_db"):     chosen.volume_db = settings.volume_db
	else:                             chosen.volume_db = 0.0
	if settings.has("pitch_scale"):   chosen.pitch_scale = settings.pitch_scale
	else:                             chosen.pitch_scale = 1.0
	if settings.has("max_distance"):  chosen.max_distance = settings.max_distance
	if settings.has("attenuation"):   chosen.attenuation = settings.attenuation
	
	chosen.play()
