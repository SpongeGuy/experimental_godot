@tool
extends Ability
class_name AbilityCrystalIncrementScore

var sound: AudioStream = preload("res://assets/sounds/crystal/crystal_pickup.wav")

# return false if activation fails in some way
func activate(master: Entity, direction: Vector2) -> bool:
	master.score += 1
	AudioManager.play_at_position(sound, master.global_position)
	return true


