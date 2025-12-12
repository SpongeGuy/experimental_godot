@tool
extends Node
class_name MusicPlaylist

@export var music_player: AudioStreamPlayer

# Preload your 6 music tracks here (replace paths with your actual .ogg/.mp3 files)
var music_tracks: Array[AudioStream] = [
	preload("res://assets/sounds/music/Ancient-screw.mp3"),
	preload("res://assets/sounds/music/A-pop-riff-for-ants.mp3"),
	preload("res://assets/sounds/music/Dream-merchant.mp3"),
	preload("res://assets/sounds/music/Resting-sand.mp3"),
	preload("res://assets/sounds/music/Waiting-signal.mp3"),
	preload("res://assets/sounds/music/Until-next-time.mp3")
]

var current_track_index: int = 0

func _ready() -> void:
	if music_tracks.is_empty() or not music_player:
		push_warning("MusicPlaylist: No tracks or player assigned!")
		return
	
	music_player.finished.connect(_on_track_finished)
	_play_current_track()

func _play_current_track() -> void:
	music_player.stream = music_tracks[current_track_index]
	music_player.play()

func _on_track_finished() -> void:
	current_track_index = (current_track_index + 1) % music_tracks.size()
	_play_current_track()
