extends Node

var players: Array[AudioStreamPlayer2D] = []

func _ready() -> void:
	for i in range(1, 12):
		var player = AudioStreamPlayer2D.new()
		add_child(player)
		
	for node in get_children():
		if node is AudioStreamPlayer2D:
			players.append(node)
			node.max_distance = 500
			
func play_sound(stream: AudioStream, position: Vector2):
	var stream_player: AudioStreamPlayer2D
	if players.is_empty():
		push_error("No AudioStreamPlayers in AudioManager!")
	for player in players:
		if not player.playing:
			stream_player = player
	if not stream_player:
		# no inactive audio stream player could be found 
		return
	stream_player.position = position
	stream_player.stream = stream
	
