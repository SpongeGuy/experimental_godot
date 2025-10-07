extends Area2D


@onready var animator = $AnimationPlayer

var user: CharacterBody2D
var user_weapon: Weapon
var last_animation: String

func _ready() -> void:
	user = get_parent()
	for node in user.get_children():
		if node is Weapon:
			user_weapon = node

func swing():
	if not last_animation or last_animation == "slash_right":
		last_animation = "slash_left"
	
	elif last_animation == "slash_left":
		last_animation = "slash_right"
	
	animator.current_animation = last_animation
		
func _signal_received(effects: Dictionary):
	print("hi")
