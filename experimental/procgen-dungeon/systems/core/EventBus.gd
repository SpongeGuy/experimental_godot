extends Node

# reactives
signal creature_damaged(creature: Creature, amount: float, source: Node2D)
signal creature_healed(creature: Creature, amount: float, source: Node2D)
signal creature_died(creature: Creature, killer: Node2D)
signal creature_satiated_hunger(creature: Creature, amount: float)
signal creature_got_hunger(creature: Creature, amount: float)

# intent to change
signal try_change_creature_health(target: Creature, amount: float, source: Node2D)
signal try_change_creature_hunger(target: Creature, amount: float)
