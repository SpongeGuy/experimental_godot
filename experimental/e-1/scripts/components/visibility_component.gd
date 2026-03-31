extends Component
class_name VisibilityComponent


# ---------------------------------------------
# changes visibility of all sprites in the array
# ---------------------------------------------


@export var sprites: Array[Sprite2D]

var _visible: bool = true

signal visibility_changed(to: bool)

func set_visibility(to: bool) -> void:
	_visible = to
	visibility_changed.emit(to)
	if to == true:
		for sprite in sprites:
			sprite.visible = true
	else:
		for sprite in sprites:
			sprite.visible = false
