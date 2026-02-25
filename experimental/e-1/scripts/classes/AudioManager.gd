extends Node

## AudioManager - Global singleton for reliable 2D audio playback
## Handles multiple simultaneous sounds without glitches using object pooling

## Pool of available AudioStreamPlayer2D nodes
var _audio_pool: Array[AudioStreamPlayer2D] = []
## Currently active players
var _active_players: Array[AudioStreamPlayer2D] = []
## Initial pool size
const INITIAL_POOL_SIZE: int = 20
## Maximum pool size (prevents memory issues)
const MAX_POOL_SIZE: int = 100

## Audio bus names for different categories
enum AudioBus {
	MASTER,
	SFX,
	MUSIC,
	UI
}

## Bus name mapping
const BUS_NAMES = {
	AudioBus.MASTER: "Master",
	AudioBus.SFX: "SFX",
	AudioBus.MUSIC: "Music",
	AudioBus.UI: "UI"
}


func _ready() -> void:
	# Initialize the audio player pool
	_initialize_pool()
	print("AudioManager initialized with pool size: ", INITIAL_POOL_SIZE)


## initialize the object pool with AudioStreamPlayer2D nodes
func _initialize_pool() -> void:
	for i in range(INITIAL_POOL_SIZE):
		_create_audio_player()


## Create a new AudioStreamPlayer2D and add it to the pool
func _create_audio_player() -> AudioStreamPlayer2D:
	var player := AudioStreamPlayer2D.new()
	player.name = "PooledAudioPlayer2D_%d" % _audio_pool.size()
	add_child(player)
	player.finished.connect(_on_player_finished.bind(player))
	_audio_pool.append(player)
	return player


## get an available player from the pool or create a new one
func _get_available_player() -> AudioStreamPlayer2D:
	# Try to get a player from the pool
	if _audio_pool.size() > 0:
		var player = _audio_pool.pop_back()
		_active_players.append(player)
		return player
	
	# If pool is empty and we haven't hit the max, create a new one
	if get_child_count() < MAX_POOL_SIZE:
		var player = _create_audio_player()
		_active_players.append(player)
		return player
	
	# Pool exhausted - find the oldest active player and reuse it
	print("AudioManager: Pool exhausted, reusing oldest player")
	var oldest_player = _active_players[0]
	oldest_player.stop()
	return oldest_player


## Return a player to the pool when finished
func _on_player_finished(player: AudioStreamPlayer2D) -> void:
	if player in _active_players:
		_active_players.erase(player)
		_audio_pool.append(player)


## Play a sound at a specific position in the world
func play_sound_at_position(
	sound: AudioStream,
	position: Vector2,
	volume_db: float = 0.0,
	pitch_scale: float = 1.0,
	bus: AudioBus = AudioBus.SFX,
	max_distance: float = 2000.0,
	attenuation: float = 1.0
) -> AudioStreamPlayer2D:
	if sound == null:
		push_error("AudioManager: Attempted to play null sound")
		return null
	
	var player = _get_available_player()
	
	# Configure the player
	player.stream = sound
	player.global_position = position
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.bus = BUS_NAMES[bus]
	player.max_distance = max_distance
	player.attenuation = attenuation
	
	# Play the sound
	player.play()
	
	return player


## Play a non-positional sound (plays at the same volume everywhere)
## Useful for UI sounds or global events
## @param sound: The AudioStream to play
## @param volume_db: Volume in decibels
## @param pitch_scale: Pitch multiplier
## @param bus: Audio bus to use (default is UI)
## @return: The AudioStreamPlayer2D that is playing the sound
func play_sound(
	sound: AudioStream,
	volume_db: float = 0.0,
	pitch_scale: float = 1.0,
	bus: AudioBus = AudioBus.UI
) -> AudioStreamPlayer2D:
	if sound == null:
		push_error("AudioManager: Attempted to play null sound")
		return null
	
	var player = _get_available_player()
	
	# Configure the player for non-positional audio
	player.stream = sound
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.bus = BUS_NAMES[bus]
	player.max_distance = 0.0  # 0 means no attenuation (plays everywhere)
	
	# Play the sound
	player.play()
	
	return player


## Play a sound with random pitch variation (great for footsteps, impacts, etc.)
## @param sound: The AudioStream to play
## @param position: The global 2D position
## @param min_pitch: Minimum pitch scale
## @param max_pitch: Maximum pitch scale
## @param volume_db: Volume in decibels
## @param bus: Audio bus to use
func play_sound_with_random_pitch(
	sound: AudioStream,
	position: Vector2,
	min_pitch: float = 0.9,
	max_pitch: float = 1.1,
	volume_db: float = 0.0,
	bus: AudioBus = AudioBus.SFX
) -> AudioStreamPlayer2D:
	var random_pitch = randf_range(min_pitch, max_pitch)
	return play_sound_at_position(sound, position, volume_db, random_pitch, bus)


## Stop all currently playing sounds
func stop_all_sounds() -> void:
	for player in _active_players:
		player.stop()


## Stop all sounds on a specific bus
func stop_sounds_on_bus(bus: AudioBus) -> void:
	var bus_name = BUS_NAMES[bus]
	for player in _active_players:
		if player.bus == bus_name:
			player.stop()


## Get the number of currently active sounds
func get_active_sound_count() -> int:
	return _active_players.size()


## Get the total pool size
func get_pool_size() -> int:
	return _audio_pool.size() + _active_players.size()


## Set the volume of a specific bus
func set_bus_volume(bus: AudioBus, volume_db: float) -> void:
	var bus_index = AudioServer.get_bus_index(BUS_NAMES[bus])
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, volume_db)


## Get the volume of a specific bus
func get_bus_volume(bus: AudioBus) -> float:
	var bus_index = AudioServer.get_bus_index(BUS_NAMES[bus])
	if bus_index >= 0:
		return AudioServer.get_bus_volume_db(bus_index)
	return 0.0


## Mute or unmute a specific bus
func set_bus_mute(bus: AudioBus, muted: bool) -> void:
	var bus_index = AudioServer.get_bus_index(BUS_NAMES[bus])
	if bus_index >= 0:
		AudioServer.set_bus_mute(bus_index, muted)


## Check if a bus is muted
func is_bus_muted(bus: AudioBus) -> bool:
	var bus_index = AudioServer.get_bus_index(BUS_NAMES[bus])
	if bus_index >= 0:
		return AudioServer.is_bus_mute(bus_index)
	return false
