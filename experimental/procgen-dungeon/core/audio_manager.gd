extends Node

var max_players: int = 24
var sound_players: Array[AudioStreamPlayer2D] = []
var leeway_distance: float = 5.0

func _ready() -> void:
	var world = get_tree().root.get_node("WorldManager")
	if world:
		var container = Node.new()
		world.add_child(container)
		for i in range(max_players):
			var player = AudioStreamPlayer2D.new()
			player.max_distance = 500
			player.attenuation = 1
			player.bus = "Master"
			player.max_polyphony = 4
			player.finished.connect(_on_sound_finished.bind(player))
			container.add_child(player)
			sound_players.append(player)
	else:
		push_error("ERROR: World node not found while initializing AudioManager players.")
				
	print("AudioManager initialized with %d players" % sound_players.size())

func _on_sound_finished(player: AudioStreamPlayer2D) -> void:
	player.stream = null
	player.pitch_scale = 1
	player.volume_db = 0

func play_sound(stream: AudioStream, position: Vector2, settings: Dictionary = {}):
	var sound_settings = {
		"stream": null,
		"position": Vector2.ZERO,
		"volume_db": 0.0,
		"pitch_scale": 1.0,
		"max_distance": 500.0,
		"attenuation": 1.0
	}
	
	for key in settings.keys():
		sound_settings[key] = settings[key]
	
	if stream:
		for player in sound_players:
			# check first for any players already at position
			if player.global_position.distance_to(position) <= leeway_distance:
				player.stream = stream
				player.global_position = position
				_apply_settings(player, settings)
				player.play()
				#print("Playing sound at ", position)
				return
		for player in sound_players:
			# now check for inactive players
			if not player.playing:
				player.stream = stream
				player.global_position = position
				_apply_settings(player, settings)
				player.play()
				#print("Playing sound at ", position)
				return
		print("Warning: No available AudioStreamPlayer2D for sound at ", position)

func _apply_settings(player: AudioStreamPlayer2D, settings: Dictionary) -> void:
	player.volume_db = settings.get("volume_db", 0.0)
	player.pitch_scale = settings.get("pitch_scale", 1.0)
	player.max_distance = settings.get("max_distance", 500.0)
	player.attenuation = settings.get("attenuation", 1.0)
