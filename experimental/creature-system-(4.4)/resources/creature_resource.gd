class_name CreatureResource extends Resource

@export var name: String
@export var faction: String # possible factions (player, herbivore, omnivore, carnivore, evil, boss)
@export var animations: Dictionary = {}

# base values
@export_category("Constant Base Statistics")
@export var base_health: float = 0.0
@export var base_movement_speed: float = 0
@export var base_attack_speed: float = 1.0
@export var base_point_value: int = 0

# modifiable values
@export_category("Modifiable Values")
@export var health: float = 0.0
@export var movement_speed: float = 0.0
@export var attack_speed: float = 1.0
@export var point_value: int = 0
