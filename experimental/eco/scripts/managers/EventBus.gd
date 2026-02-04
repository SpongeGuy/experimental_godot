extends Node

signal item_taken_from_storage(storage: Node2D, item: Node2D)

# reactives
signal creature_damaged(creature: Node2D, amount: float, source: Node2D)
signal creature_healed(creature: Node2D, amount: float, source: Node2D)
signal creature_died(creature: Node2D, killer: Node2D)
#signal creature_satiated_hunger(creature: Creature, amount: float)
#signal creature_got_hunger(creature: Creature, amount: float)
#
## intent to change
#signal try_change_creature_health(target: Creature, amount: float, source: Node2D)
#signal try_change_creature_hunger(target: Creature, amount: float)
#
## wave manager
#signal wave_started(wave_number: int, total_points: int)
#signal wave_completed(wave_number: int)
#signal entity_spawned(position: Vector2, entity: Entity)

signal added_to_inventory(inventory: Inventory, item: Node2D)
signal removed_from_inventory(inventory: Inventory, item: Node2D)


