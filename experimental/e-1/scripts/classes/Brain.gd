extends Component
class_name Brain

var _lobes: Dictionary[Script, Lobe] = {}
@export var state_machine: StateMachine
@export var memory: Memory

var personality: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
# [0] = aggression
# [1] = bravery
# [2] = dominance
# [3] = energy
# [4] = nervous
# [5] = sympathy

func _ready() -> void:
	_register_lobes(self)
	_randomize_personality()
	
func _randomize_personality() -> void:
	randomize()
	for i in personality.size():
		personality[i] = randf()
	
func _register_lobes(node: Node) -> void:
	for child in node.get_children():
		if child is Lobe:
			_add_lobe(child)
		_register_lobes(child)
		
func _add_lobe(lobe: Lobe) -> void:
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


func _evaluate() -> void:
	# evaluate lobes
	var best_lobe: Lobe
	var best_state: Array = [0, null]
	for lobe in _lobes.values():
		var state: Array = lobe.evaluate()
		if state[0] > best_state[0]:
			best_lobe = lobe
			best_state = state
	
	if not best_lobe:
		return
	best_lobe.commit(memory)
	if state_machine.current_state != best_state[1]:
		state_machine.switch(best_state[1])
