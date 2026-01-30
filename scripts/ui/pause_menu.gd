extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()


func toggle_pause():
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state


func _on_resume_button_pressed() -> void:
	toggle_pause()


func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
