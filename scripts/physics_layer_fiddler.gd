extends TileMapLayer

var base_tile_map: TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self is TileMapLayer:
		print("valid")
		base_tile_map = self
		MaskManager.mask_changed.connect(_on_mask_changed)


func _on_mask_changed(_old_mask, new_mask):
	if base_tile_map.is_in_group("future_visible") and new_mask == MaskManager.MASK.FUTURE:
		base_tile_map.collision_enabled = true
	elif base_tile_map.is_in_group("past_visible") and new_mask == MaskManager.MASK.PAST:
		base_tile_map.collision_enabled = true
	elif base_tile_map.is_in_group("present") and new_mask == MaskManager.MASK.NOW:
		base_tile_map.collision_enabled = true
	else:
		base_tile_map.collision_enabled = false
	
