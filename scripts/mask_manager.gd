extends Node

signal mask_changed(old_mask, new_mask)

signal past_mask_available
signal future_mask_available

enum MASK {PAST, NOW, FUTURE}

var current_mask = MASK.NOW
var _past_mask_enabled = false
var _future_mask_enabled = false

func _ready():
	switch_mask(current_mask)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("mask_past") and _past_mask_enabled:
		switch_mask(MASK.PAST)
	if Input.is_action_just_pressed("mask_now"):
		switch_mask(MASK.NOW)
	if Input.is_action_just_pressed("mask_future") and _future_mask_enabled:
		switch_mask(MASK.FUTURE)
		
func switch_mask(mask):
	print(mask)
	var old_mask = current_mask
	current_mask = mask
	if (current_mask == MASK.PAST):
		get_tree().call_group("show_in_now_only", "hide")
		get_tree().call_group("show_in_future", "hide")
	if (current_mask == MASK.NOW):
		get_tree().call_group("show_in_past", "hide")
		get_tree().call_group("show_in_future", "hide")
		get_tree().call_group("show_in_now_only", "show")
	if (current_mask == MASK.FUTURE):
		get_tree().call_group("show_in_past", "hide")
		get_tree().call_group("show_in_now_only", "hide")
	mask_changed.emit(old_mask, current_mask)
	
func enable_past_mask():
	past_mask_available.emit()
	_past_mask_enabled = true
	
func enable_future_mask():
	future_mask_available.emit()
	_future_mask_enabled = true
