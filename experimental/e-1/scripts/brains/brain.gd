extends Component
class_name DeprecatedBrain

var _lobes: Dictionary[Script, DeprecatedLobe] = {}
@export var state_machine: StateMachine

func _ready() -> void:
	_register_lobes(self)
	state_machine.state_switched.connect(_on_state_switched)
	setup()
	
func _register_lobes(node: Node) -> void:
	for child in node.get_children():
		if child is DeprecatedLobe:
			_add_lobe(child)
		_register_lobes(child)
		
func _add_lobe(lobe: DeprecatedLobe) -> void:
	_lobes[lobe.get_script()] = lobe
	lobe.brain = self
	lobe.changed.connect(_on_memory_changed)
	lobe._on_registered()
	
func get_lobe(type: Script) -> Variant:
	return _lobes.get(type, null)
	
func has_lobe(type: Script) -> bool:
	return _lobes.has(type)
	
func _on_memory_changed() -> void:
	_evaluate()
	
func setup() -> void: pass
func tick(delta: float) -> void: pass
func _on_state_switched(old: BehaviorState, new: BehaviorState) -> void: pass

# evaluate functions will exist down here on inherited brains
func _evaluate() -> void: pass # this is to be overridden
