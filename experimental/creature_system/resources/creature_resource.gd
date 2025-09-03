class_name CreatureResource extends Resource

@export var name: String
@export var faction: String # possible factions (player, herbivore, omnivore, carnivore, evil, boss)
@export var health: int = 0
@export var movement_speed: float = 0
@export var attack_speed: float = 1.0
@export var point_value: int = 0.0
@export var animations: Dictionary = {}
