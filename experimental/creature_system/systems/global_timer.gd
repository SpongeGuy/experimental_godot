extends Node

signal timer_started()
signal timer_paused()
signal timer_resumed()
signal timer_reset()
signal timer_finished()

var elapsed_time: float = 0.0
var is_running: bool = false
var is_countdown: bool = true

func _process(delta: float) -> void:
	if is_running:
		if is_countdown:
			elapsed_time -= delta
		else:
			elapsed_time += delta
	if elapsed_time <= 0:
		if is_running:
			is_running = false
			timer_finished.emit()
	
		
func start() -> void:
	if not is_running:
		is_running = true
		timer_started.emit()
		if elapsed_time == 0.0:
			timer_reset.emit()
		else:
			timer_resumed.emit()

func pause() -> void:
	if is_running:
		is_running = false
		timer_paused.emit()
		
func reset() -> void:
	elapsed_time = 0.0
	is_running = false
	timer_reset.emit()
	
func get_formatted_time() -> String:
	var seconds = int(elapsed_time) % 60
	var minutes = int(elapsed_time / 60) % 60
	return "%02d:%02d" % [minutes, seconds]
	
func  get_elapsed_time() -> float:
	return elapsed_time
	
func set_elapsed_time(time: float) -> void:
	elapsed_time = max(0.0, time)

