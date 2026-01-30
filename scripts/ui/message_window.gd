extends Control

@onready var message_label: Label = $PopupBox/TextContainer/MessageLabel

func _ready() -> void:
	hide()

func open(text: String):
	message_label.text = text
	show()

func _on_close_button_pressed() -> void:
	hide()
