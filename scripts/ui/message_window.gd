extends Control

@onready var message_label: Label = $PopupBox/TextContainer/MessageLabel

func open(text: String):
	message_label.text = text

func _on_close_button_pressed() -> void:
	get_tree().quit(0)	
