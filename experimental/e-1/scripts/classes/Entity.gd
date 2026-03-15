extends CharacterBody2D
class_name Entity

var _components: Dictionary[Script, Component] = {}

signal entity_initialized

func _ready() -> void:
	_register_components(self)
	entity_initialized.emit()
	
func _register_components(node: Node) -> void:
	for child in node.get_children():
		if child is Component:
			add_component(child)
		_register_components(child)

func add_component(component: Component) -> void:
	_components[component.get_script()] = component
	component._on_registered()
	component.entity = self
	
func get_component(type: Script) -> Variant:
	return _components.get(type, null)
	
func has_component(type: Script) -> bool:
	
	return _components.has(type)

