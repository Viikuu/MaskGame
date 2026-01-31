extends Node

signal mask_changed(old_mask, new_mask)

enum MASK {PAST, NOW, FUTURE}

var current_mask = MASK.NOW

func _ready():
	switch_mask(current_mask)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("mask_past"):
		switch_mask(MASK.PAST)
	if Input.is_action_just_pressed("mask_now"):
		switch_mask(MASK.NOW)
	if Input.is_action_just_pressed("mask_future"):
		switch_mask(MASK.FUTURE)
		
func switch_mask(mask):
	var old_mask = current_mask
	current_mask = mask
	mask_changed.emit(old_mask, current_mask)
