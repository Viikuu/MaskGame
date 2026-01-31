extends Area2D

@onready var mask_effect_bubble: Area2D = $"."

func _ready():
	MaskManager.mask_changed.connect(_on_mask_changed)

func _on_body_entered(body: Node2D) -> void:
	_evaluate_body_enter(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("show_in_future") and MaskManager.current_mask == MaskManager.MASK.FUTURE:
		body.hide()
	if body.is_in_group("show_in_past") and MaskManager.current_mask == MaskManager.MASK.PAST:
		body.hide()
		
func _evaluate_body_enter(body: Node2D):
	if body.is_in_group("show_in_future") and MaskManager.current_mask == MaskManager.MASK.FUTURE:
		body.show()
	if body.is_in_group("show_in_past") and MaskManager.current_mask == MaskManager.MASK.PAST:
		body.show()

func _on_mask_changed(old_mask, new_mask):
	for body in mask_effect_bubble.get_overlapping_bodies():
		_evaluate_body_enter(body)
