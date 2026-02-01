extends TileMapLayer

var base_tile_map: TileMapLayer

# Map mask -> group that should have collisions ENABLED in that mask
const MASK_TO_GROUP := {
	MaskManager.MASK.FUTURE: &"show_in_future",
	MaskManager.MASK.PAST: &"show_in_past",
	MaskManager.MASK.NOW: &"show_in_now_only",
}

func _ready() -> void:
	# This script is attached to a TileMapLayer, so this is always true,
	# but keeping your style / safety check.
	if self is TileMapLayer:
		print("valid")
		base_tile_map = self
		MaskManager.mask_changed.connect(_on_mask_changed)

# --- helpers ----------------------------------------------------------

func _set_node_collisions_enabled(root: Node, enabled: bool) -> void:
	# CollisionShape2D is usually what you have (your screenshots)
	for s in root.find_children("*", "CollisionShape2D", true, false):
		(s as CollisionShape2D).disabled = not enabled

	# If you ever use polygons too
	for p in root.find_children("*", "CollisionPolygon2D", true, false):
		(p as CollisionPolygon2D).disabled = not enabled


func _set_group_collisions_enabled(group_name: StringName, enabled: bool) -> void:
	for root in get_tree().get_nodes_in_group(group_name):
		_set_node_collisions_enabled(root, enabled)

# --- main ------------------------------------------------------------

func _on_mask_changed(old_mask, new_mask) -> void:
	# 1) TileMapLayer collision stays exactly like your logic
	match new_mask:
		MaskManager.MASK.FUTURE:
			base_tile_map.collision_enabled = base_tile_map.is_in_group("future_visible")
		MaskManager.MASK.PAST:
			base_tile_map.collision_enabled = base_tile_map.is_in_group("past_visible")
		MaskManager.MASK.NOW:
			base_tile_map.collision_enabled = true
		_:
			base_tile_map.collision_enabled = false

	# 2) Disable collisions for the group we are LEAVING (old_mask)
	var old_group: StringName = MASK_TO_GROUP.get(old_mask, &"")
	if old_group != &"":
		_set_group_collisions_enabled(old_group, false)

	# 3) Enable collisions for the group we are ENTERING (new_mask)
	var new_group: StringName = MASK_TO_GROUP.get(new_mask, &"")
	if new_group != &"":
		_set_group_collisions_enabled(new_group, true)
