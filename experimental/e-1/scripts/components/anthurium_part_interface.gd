extends Component
class_name AnthuriumPartInterface

# ------------------------------------------
# ALWAYS SPAWN PLANT PARTS FROM HERE SO THAT THEY CAN ATTACH OWNERSHIP
# if certain plant parts do not have the anthurium linked, they will not function correctly
# ----------------------------------------------

func spawn_pitcher(pos: Vector2) -> void:
	var pitcher: Entity = EntityManager.spawn_safely(&"pitcher", pos)
	set_part_ownership(pitcher)

func spawn_roots(pos: Vector2) -> void:
	var roots: Entity = EntityManager.spawn_safely(&"roots", pos)
	set_part_ownership(roots)

func set_part_ownership(e: Entity) -> void:
	var part: AnthuriumPart = e.get_component(AnthuriumPart)
	if not part:
		return
	part.anthurium = entity
