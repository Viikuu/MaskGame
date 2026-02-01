extends BaseMenu

@onready var about_window: Control = $AboutWindow	
@onready var start_game: Button = $LeftContainer/ButtonContainer/VBoxContainer/StartGame


func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_level_design.tscn")


func _on_about_pressed() -> void:
	about_window.open("Dżosz is a great thief that travels through time to pet cats and stop evil wizards")


func _on_quit_pressed() -> void:
	get_tree().quit(0)
