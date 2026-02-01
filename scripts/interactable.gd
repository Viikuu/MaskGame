extends Area2D
class_name Interactable

@export var only_once = false
@export var text = ''
@export var text_x_offset = 0
@export var text_y_offset = -15
@onready var interactable_text: Label = $InteractableText

signal interacted

func _ready():
	for parent_group in get_parent().get_groups():
		if parent_group.begins_with("show_in"):
			add_to_group(parent_group)
	
func interact():
	interacted.emit()
	if (only_once):
		get_parent().queue_free()
		queue_free()
	
func _draw() -> void:
	if interactable_text:
		interactable_text.text = text
		var new_pos = Vector2(interactable_text.position)
		new_pos.x += text_x_offset
		new_pos.y += text_y_offset
		interactable_text.set_position(new_pos)

func can_interact():
	if is_in_group("show_in_past") and MaskManager.current_mask != MaskManager.MASK.PAST:
		return false
	if is_in_group("show_in_now_only") and MaskManager.current_mask != MaskManager.MASK.NOW:
		return false
	if is_in_group("show_in_future") and MaskManager.current_mask != MaskManager.MASK.FUTURE:
		return false
		
	if owner.has_method("can_interact"):
		return owner.can_interact()
		
	return true
