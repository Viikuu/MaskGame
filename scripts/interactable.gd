extends Area2D
class_name Interactable

@export var only_once = false

signal interacted

func _ready():
	for parent_group in get_parent().get_groups():
		if parent_group.begins_with("show_in"):
			add_to_group(parent_group)

func interact():
	interacted.emit()
	if (only_once):
		get_parent().queue_free()
		

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
