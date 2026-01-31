extends Control
class_name BaseMenu

@export var first_button: Button

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		print("dupa")
		if get_viewport().gui_get_focus_owner() == null:
			first_button.grab_focus()
			get_viewport().set_input_as_handled()
			
