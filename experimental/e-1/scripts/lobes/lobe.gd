extends Node
class_name Lobe

# ------------------------------------------------------------------------------------------
# a component for a Brain component.
# holds references to other components and reacts to their signals
# holds vital information in memory
# when this information is changed, emit signal changed
# this signal will be transmitted to the brain which will then evaluate all memory to decide to change states
# ------------------------------------------------------------------------------------------


var brain: Brain

signal changed

func _on_registered() -> void: pass # to be overridden


