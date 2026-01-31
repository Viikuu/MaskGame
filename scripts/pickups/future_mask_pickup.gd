extends Node

@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.interacted.connect(_on_mask_pickup_interacted)

func _on_mask_pickup_interacted():
	MaskManager.enable_future_mask()
	MaskManager.switch_mask(MaskManager.MASK.FUTURE)
	pass
