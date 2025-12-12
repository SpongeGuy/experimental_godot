extends Creature
class_name Devil


var leader_since

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	leader_since = Time.get_ticks_msec()
	EventBus.creature_damaged.connect(_replenish_hunger)
	name = "Devil"


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _replenish_hunger(creature: Creature, amount: float, source: Node2D) -> void:
	if source == self:
		
		EventBus.try_change_creature_hunger.emit(self, amount * 15)
		
