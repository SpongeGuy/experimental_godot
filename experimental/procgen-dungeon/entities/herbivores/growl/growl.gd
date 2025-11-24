class_name Growl
extends Creature

var aggression_area: Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	entity_type = "Growl"
	
	aggression_area = $AggressionArea
	aggression_area.collision_mask = (1 << 2) | (1 << 4)
	bt_player.blackboard.set_var("aggression_area", aggression_area)
	
	super._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
