extends Node

@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.interacted.connect(_on_key_interacted)
	
func _on_key_interacted():
	print("key has been picked up")
