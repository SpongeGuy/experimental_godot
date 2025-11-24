class_name CreatureStats extends Resource

@export_category("Identification")
@export var entity_class: String = "Creature"
@export var entity_type: String = ""
@export var uuid: String
@export var entity_faction: CreatureFactions

enum CreatureFactions {
	Herbivore,
	Carnivore
}

@export_category("Stats")
@export var max_health: int = 5
@export var max_hunger: float = 1000
@export var hunger_rate: float = 4.0 # per second
@export var base_speed: float = 120.0
