extends Node

@onready var interactable: Interactable = $Interactable
#
func _ready() -> void:
	interactable.interacted.connect(_on_lever_handle_interacted)
	
func can_interact():
	return InventoryManager.current_item == null

func _on_lever_handle_interacted():
	print("lever handle has been picked up")
	InventoryManager.add_item(Item.LeverHandle.new())
