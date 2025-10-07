extends AIState

@export var seeking_state: AIState

var nav_agent: NavigationAgent2D
var seek_target: Vector2

func _ready() -> void:
	nav_agent = get_parent().navigation_agent
	if not nav_agent:
		push_error("State is missing navigation agent!")

func enter(creature: Creature) -> void:
	super.enter(creature)
	nav_agent.set_target_position(Vector2(400, 400))
		
func exit(creature: Creature) -> void:
	super.exit(creature)

func update(creature: Creature, delta: float) -> AIState:
	super.update(creature, delta)
	update_navigation(creature)
	return null

func update_navigation(creature: Creature) -> void:
	if nav_agent.is_navigation_finished():
		creature.velocity = Vector2.ZERO
		return
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - creature.global_position).normalized()
	creature.velocity = direction * creature.creature_stats.movement_speed
	
	
