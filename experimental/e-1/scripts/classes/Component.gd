extends Node
class_name Component

var entity: Entity

func _on_registered() -> void:
	pass

#func _ready() -> void:
	#assert(entity != null, "%s: component has no entity. Is it a descendant of an Entity node?" % name)
