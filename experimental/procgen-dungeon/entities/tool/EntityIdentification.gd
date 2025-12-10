extends Resource
class_name EntityIdentification

@export_category("Identification")
@export var entity_class: String = ""
@export var entity_type: String = ""
## Leave this blank if you want it to randomly generate a new uuid on creation.
@export var uuid: String
@export var entity_faction: CreatureFactions

enum CreatureFactions {
	Herbivore,
	Carnivore,
	Plant,
	ActivateableItem,
	PassiveItem
}
