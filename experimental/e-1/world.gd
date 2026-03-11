extends Node2D

@onready var entity_container: Node2D = $Entities
@export var world_generator: WorldGenerator

func _ready() -> void:
	if entity_container:
		GameManager.entity_container = entity_container
		
	WorldGrid.init_grid(32, 32)
	world_generator.generate()

	#for y in range(WorldGrid.height):
		#for x in range(WorldGrid.width):
			#WorldGrid.mutate(Vector2i(x, y), "terrain", CellData.TerrainType.GROUND)

	
