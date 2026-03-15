extends Component
class_name RecentlyInteracted

# -----------------------------------------
# gets various sources (a collision box, an area, etc)
# connects up signals to set a recently_interacted variable
# this recently_interacted variable gets set to null if it hasnt been set for an amount of time
# -----------------------------------------

@export var expire_time: float = 3
var _timer: float = 0.0
var recently_interacted: Entity

func _process(delta: float) -> void:
	if _timer > 0:
		_timer -= delta

func interact(e: Entity) -> void:
	_timer = expire_time
	recently_interacted = e
