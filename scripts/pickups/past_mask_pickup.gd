extends Node

@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.interacted.connect(_on_mask_pickup_interacted)

func _on_mask_pickup_interacted():
	MaskManager.enable_past_mask()
	MaskManager.switch_mask(MaskManager.MASK.PAST)
	pass
