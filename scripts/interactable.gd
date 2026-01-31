extends Area2D
class_name Interactable

@export var only_once = false

signal interacted

func interact():
	interacted.emit()
	if (only_once):
		get_parent().queue_free()
