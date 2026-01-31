extends Node

@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.interacted.connect(_on_key_interacted)
	
func can_interact():
	return InventoryManager.current_item == null

func _on_key_interacted():
	print("key has been picked up")
	InventoryManager.add_item(Item.Key.new())
