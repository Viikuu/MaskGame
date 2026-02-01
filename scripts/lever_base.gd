extends Node
class_name LeverBase

signal lever_opened

@onready var interactable: Interactable = $Interactable

enum LeverState { BROKEN, CLOSED, OPEN }

var current_state = LeverState.BROKEN

func _ready() -> void:
	interactable.interacted.connect(_on_lever_interacted)
	
func can_interact():
	if current_state == LeverState.BROKEN:
		return InventoryManager.current_item is Item.LeverHandle
	return current_state == LeverState.CLOSED

func _on_lever_interacted():
	if current_state == LeverState.BROKEN:
		InventoryManager.use_item()
		_switch_to_closed()
	else:
		_switch_to_open()
		
#
func _switch_to_closed():
	current_state = LeverState.CLOSED
	$LeverHandle.show()
	
func _switch_to_open():
	current_state = LeverState.OPEN
	$LeverHandle/LeverHandleAnimation.play("open")
	lever_opened.emit()
