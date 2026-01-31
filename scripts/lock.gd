extends Node

@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.interacted.connect(_on_lock_interacted)
	
func can_interact():
	return InventoryManager.current_item is Item.Key

func _on_lock_interacted():
	print("lock has been unlocked")
	InventoryManager.use_item()
