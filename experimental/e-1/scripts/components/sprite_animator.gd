extends Component
class_name SpriteAnimator

@export var sprite: Sprite2D

@export var animations: Array[SpriteAnimation]

var current_animation: SpriteAnimation
var current_frame: int = 0
var animation_timer: float = 0.0

var stopped: bool = false

signal animation_finished(animation: SpriteAnimation)
signal animation_loaded(animation: SpriteAnimation)
signal frame_elapsed(frame: int)

	
func update_animation(delta: float, modifier: float = 1.0) -> void:
	if not current_animation:
		return
	
	if stopped:
		return
	
	var old_frame: int = current_frame
	animation_timer += delta * modifier * current_animation.speed
	if animation_timer >= current_animation.frames:
		animation_timer = 0.0
		if not current_animation.loop:
			animation_finished.emit(SpriteAnimation)
			stop()
			
	if not current_animation:
		return
	
	current_frame = floor(animation_timer)
	
	if old_frame != current_frame:
		frame_elapsed.emit(current_frame)
	sprite.frame_coords = Vector2i(current_frame, current_animation.row)
	
func stop() -> void:
	stopped = true
	
func play() -> void:
	stopped = false

func load_and_reset_animation(animation_name: StringName) -> void:
	if current_animation and animation_name == current_animation.name:
		return
	for animation in animations:
		if animation.name != animation_name:
			continue
		current_animation = animation
	current_frame = 0
	animation_timer = 0.0
	play()
	animation_loaded.emit(current_animation)
	
func load_animation(animation_name: StringName) -> void:
	if current_animation and animation_name == current_animation.name:
		return
	for animation in animations:
		if animation.name != animation_name:
			continue
		current_animation = animation
	play()
	animation_loaded.emit(current_animation)
	
func reset_animation() -> void:
	current_frame = 0
	animation_timer = 0.0
	play()
