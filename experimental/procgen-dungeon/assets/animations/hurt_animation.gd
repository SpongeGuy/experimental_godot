extends AnimationPlayer
class_name HurtAnimation


@export var graphics_nodes: Array[CanvasItem] = []

var global_library: AnimationLibrary

func _ready() -> void:
	if not has_animation_library(""):
		add_animation_library("", AnimationLibrary.new())
	global_library = get_animation_library("")
	if not has_animation("hurt"):
		_create_hurt_animation()
		stop()
		seek(0.2, true)
		
func play_hurt() -> void:
	for node in graphics_nodes:
		if node and is_instance_valid(node):
			node.modulate = Color.WHITE
	stop()
	play("hurt")

func _create_hurt_animation() -> void:
	var animation: Animation = Animation.new()
	animation.length = 0.2
	animation.loop_mode = Animation.LOOP_NONE
	global_library.add_animation("hurt", animation)
	
	for node in graphics_nodes:
		if not node or not is_instance_valid(node):
			continue
			
		var path: NodePath = node.get_path_to(node)
		
		var track_idx: int = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_idx, str(path, ":modulate"))
		
		animation.track_insert_key(track_idx, 0.00, Color(1, 0, 0, 1))
		animation.track_insert_key(track_idx, 0.10, Color(1, 1, 1, 1))
		animation.track_insert_key(track_idx, 0.20, Color(1, 1, 1, 1))
	
		animation.value_track_set_update_mode(track_idx, Animation.UPDATE_CONTINUOUS)
		animation.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_LINEAR)
