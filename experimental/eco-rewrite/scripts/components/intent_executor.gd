extends Node
class_name IntentExecutor

@export var master_origin: Node2D
@export var brain: Brain
var previous_intent: Intent
var current_intent: Intent
var action_handlers: Dictionary[String, Callable] = {}

func _ready() -> void:
	# components will register their own action handlers
	_discover_component_handlers()
	
	if brain:
		brain.intent_changed.connect(_on_intent_changed)
	
func _on_intent_changed(old_intent: Intent, new_intent: Intent) -> void:
	current_intent = new_intent
	previous_intent = old_intent
	
func _discover_component_handlers() -> void:
	for child in master_origin.get_children():
		if child.has_method("register_action_handlers"):
			child.register_action_handlers(self)
	
func register_action(action_name: String, handler: Callable) -> void:
	action_handlers[action_name] = handler
	
func execute_intent(delta: float) -> void:
	if not current_intent:
		return
	if action_handlers.has(current_intent.action):
		action_handlers[current_intent.action].call(delta, current_intent)
	else:
		_try_component_dispatch(delta, current_intent)
	
func _try_component_dispatch(delta: float, intent: Intent) -> void:
	# try to find a component that can handle this situation
	for child in master_origin.get_children():
		if child.has_method("handle_intent"):
			if child.handle_intent(delta, intent):
				return # component handled it
