extends AIState

@export var seeking_state: AIState

var nav_agent: NavigationAgent2D
var wander_target: Vector2

func _ready() -> void:
	nav_agent = get_parent().navigation_agent
	if not nav_agent:
		push_error("State is missing navigation agent!")
	

func enter(creature: Creature) -> void:
	super.enter(creature)
	#nav_agent.set_target_position(Vector2(1200, 1200))

		
func exit(creature: Creature) -> void:
	super.exit(creature)

func update(creature: Creature, delta: float) -> AIState:
	super.update(creature, delta)
	
	return null


