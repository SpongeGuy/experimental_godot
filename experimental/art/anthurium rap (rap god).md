anthurium rap (rap god)
========================
I'm making a game about emergent behaviors.

Rain world is a game about exploration and being in the middle of the food chain in a bizarre ecosystem.
But what if there was a snappy arcade version of that?

Elements:
- terrain (dynamic, destructible)
- fruit (different visual styles per item but functionally the same)
- creatures which behave based on simple rules to allow for emergence

### Food chain
|entity type| behaviors |
|---|---|
|carnivore| designates an area as its nest and builds webs. if all the webs are broken it will flee and designate a new area. wanders around and seeks carnivores and herbivores. picks up creatures and throws them into webs. if a creature has spent more than 10 seconds in the web, seeks and eats the creature. |
|carnivore| seeks others of its kind. stays in packs and seeks and kills herbivores when hungry |
|carnivore| prowls around, keeping herbivores in range. kills when hungry|
|carnivore| hops from tile to tile. hops towards herbivores and kills when hungry |
|herbivore| wanders around aimlessly. seeks and eats fruit when hungry. will bite creatures who come too close. |
|herbivore| wanders around aimlessly. seeks and eats fruit when hungry. passively shoots pellets at threatening creatures. |
|herbivore| the player |
|herbivore| wanders around aimlessly. seeks and eats fruit when hungry. |
|herbivore| sits around until predators are around, then runs away. seeks out areas where fruit is high quantity |
|herbivore| creates little copies of itself to deliver fruit to the mother|
|herbivore| wanders around aimlessly. seeks and eats fruit when hungry. runs away from threatening creatures. if there are too many threatening creatures nearby, it will detonate. |
|plant| produces fruit every 15 seconds |
|fruit| satiates a herbivore's hunger. if untouched for more than a minute, disappears and has a chance to grow a new plant. |

### BTActions
```
get [Object] within [radius]
get random Vector2 within [radius] at [Vector2]
explode [radius] at [Vector2]
pathfind away from [Object]
summon [Object] at [Vector2]
shoot pellet [Object]
```

### Generic entity type
```gdscript
var health: float
var position: Vector2
var behaviors: BTPlayer # LimboAI
```



how should i handle collisions? some entities will be able to clip through other entities or terrain. others will not be allowed to occupy the same space as another entity. however, entities should never get stuck together.