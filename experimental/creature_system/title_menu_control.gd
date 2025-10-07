extends Control


func _ready():
	$VBoxContainer/PlayButton.grab_focus()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
