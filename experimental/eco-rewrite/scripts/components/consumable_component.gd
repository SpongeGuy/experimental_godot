extends Node
class_name ConsumableComponent

@export var sprite: Sprite2D
@export var current_stage: int = 0
@export var total_stages: int = 5 # auto set if sprite.hframes exists

signal stage_changed(old_stage: int, new_stage: int)
signal fully_consumed



func _ready():
	if sprite and sprite.hframes > 0:
		total_stages = sprite.hframes
		
	_update_sprite()
	
func _update_sprite() -> void:
	if not sprite:
		return
		
	var frame = clamp(current_stage, 0, sprite.hframes - 1)
	sprite.frame = frame
	
func advance_stage() -> void:
	var old_stage = current_stage
	current_stage += 1
	
	_update_sprite()
	
	stage_changed.emit(old_stage, current_stage)
	
	if is_fully_consumed():
		fully_consumed.emit()
		
func reset_stage() -> void:
	var old_stage = current_stage
	current_stage = 0
	
	_update_sprite()
	
	stage_changed.emit(old_stage, current_stage)
		
func is_fully_consumed() -> bool:
	return current_stage >= total_stages
