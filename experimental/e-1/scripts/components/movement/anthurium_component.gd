extends Component
class_name AnthuriumComponent

# ---------------------------------
# registers the entity to the anthurium brain!
# ---------------------------------

var basename: StringName
var pissar: StringName = &"pissar"

var parts: Dictionary[StringName, int] = {
	&"pissar": 2
}

# Called when the node enters the scene tree for the first time.
func _on_registered() -> void:
	basename = entity.get_basename()
	AnthuriumBrain.add_active_part(basename)
	
func _exit_tree() -> void:
	AnthuriumBrain.remove_active_part(basename)
