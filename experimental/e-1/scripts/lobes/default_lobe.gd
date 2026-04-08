extends Lobe
class_name DefaultLobe

@export var state: BehaviorState

func evaluate() -> Array: # also to be overridden
	return [0.01, state]

# should be used to write stuff to memory
func commit(memory: Memory) -> void:
	pass
