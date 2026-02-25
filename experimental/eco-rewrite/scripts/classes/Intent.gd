class_name Intent
extends Resource

var action: String = "idle"
var priority: float = 0.0

var target_position: Vector2
var target_entity: Node
var target_entities: Array[Node]

var movement_style: String = "default"
var acceptable_distance_to_target: float = 10.0
var movement_urgency: float = 0.5

var look_target: Variant = null

var parameters: Dictionary = {}

var memory_key: String = ""
var goal_name: String = ""
var cancel_if: Array[String] = []
