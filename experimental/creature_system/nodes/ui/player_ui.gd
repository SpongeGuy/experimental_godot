extends Control

@onready var points_display: Label = $PointsDisplay
@onready var time_display: Label = $TimeDisplay
@onready var fps_display: Label = $FPSDisplay

func _ready() -> void:
	GlobalTimer.elapsed_time = 3
	GlobalTimer.start()
	
func _update_time() -> void:
	var current_time: String = GlobalTimer.get_formatted_time()
	time_display.text = current_time
	
func _process(delta: float) -> void:
	_update_time()
	fps_display.text = str(Engine.get_frames_per_second())
