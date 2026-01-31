extends Area2D
class_name RevealZone

enum Mode { PAST, NOW, FUTURE }

@export var mode: Mode = Mode.NOW
@export var active: bool = true

# Optional cap so you don't scan too much by mistake (0 = no cap)
@export var max_scan_radius_tiles: int = 0

@export var debug_logs: bool = false

@onready var _cs: CollisionShape2D = $CollisionShape2D

var _past_sources: Array[TileMapLayer] = []
var _past_visibles: Array[TileMapLayer] = []
var _future_sources: Array[TileMapLayer] = []
var _future_visibles: Array[TileMapLayer] = []

# key -> Dictionary(dst_cell -> true)
var _revealed: Dictionary[String, Dictionary] = {}
var _last_center_cell: Vector2i = Vector2i(999999, 999999)

func _ready() -> void:
	_collect_layers()
	MaskManager.mask_changed.connect(set_mode)
	if debug_logs:
		print("future src:", _future_sources.size(), "future vis:", _future_visibles.size())
		print("past src:", _past_sources.size(), "past vis:", _past_visibles.size())

func _collect_layers() -> void:
	_past_sources = _collect_sorted("past_source")
	_past_visibles = _collect_sorted("past_visible")
	_future_sources = _collect_sorted("future_source")
	_future_visibles = _collect_sorted("future_visible")

func _collect_sorted(group_name: String) -> Array[TileMapLayer]:
	var arr: Array[TileMapLayer] = []
	for n in get_tree().get_nodes_in_group(group_name):
		if n is TileMapLayer:
			arr.append(n)

	arr.sort_custom(func(a: TileMapLayer, b: TileMapLayer) -> bool:
		if a.z_index == b.z_index:
			return a.name < b.name
		return a.z_index < b.z_index
	)
	return arr

func set_mode(old_mask: Mode, new_mode: Mode) -> void:
	if mode == new_mode:
		return
	clear_all()
	mode = new_mode
	_last_center_cell = Vector2i(999999, 999999)
	if debug_logs:
		print("RevealZone mode -> ", mode)

func update_if_needed(player_world_pos: Vector2) -> void:
	if not active:
		return
	if mode == Mode.NOW:
		return

	var ref: TileMapLayer = null
	if mode == Mode.PAST and _past_sources.size() > 0:
		ref = _past_sources[0]
	elif mode == Mode.FUTURE and _future_sources.size() > 0:
		ref = _future_sources[0]

	if ref == null:
		if debug_logs: print("RevealZone: ref is null for mode=", mode)
		return

	var center_cell: Vector2i = ref.local_to_map(ref.to_local(player_world_pos))
	if center_cell == _last_center_cell:
		return
	_last_center_cell = center_cell

	if mode == Mode.PAST:
		_update_group("past", _past_sources, _past_visibles, center_cell)
	elif mode == Mode.FUTURE:
		_update_group("future", _future_sources, _future_visibles, center_cell)

func _update_group(prefix: String, sources: Array[TileMapLayer], visibles: Array[TileMapLayer], center_cell: Vector2i) -> void:
	var count: int = min(sources.size(), visibles.size())
	if count <= 0:
		if debug_logs: print("RevealZone: no pairs for ", prefix)
		return

	for i in range(count):
		_update_pair(prefix, i, sources[i], visibles[i], center_cell)

func _get_circle_radius_px() -> float:
	if _cs == null or _cs.shape == null or _cs.disabled:
		return 0.0
	var circle := _cs.shape as CircleShape2D
	if circle == null:
		return 0.0
	# Account for scaling of the CollisionShape2D node
	# (if you scaled the Area2D/CollisionShape in the editor)
	var scale_factor: float = _cs.global_scale.x if _cs.global_scale.x > _cs.global_scale.y else _cs.global_scale.y

	return circle.radius * scale_factor

func _update_pair(prefix: String, idx: int, src: TileMapLayer, dst: TileMapLayer, center_cell: Vector2i) -> void:
	var dict_key: String = prefix + ":" + str(idx)
	var old_set: Dictionary = _revealed.get(dict_key, {})
	_revealed[dict_key] = old_set
	var new_set: Dictionary = {}

	var tile_size: Vector2 = Vector2(16, 16)
	if src.tile_set:
		tile_size = src.tile_set.tile_size

	var radius_px := _get_circle_radius_px()
	if radius_px <= 0.0:
		if debug_logs:
			print("RevealZone: radius_px is 0 (shape missing/disabled/not circle)")
		return

	# Convert collider radius (pixels) -> tiles, add 1 for safety
	var radius_tiles := int(ceil(radius_px / max(tile_size.x, tile_size.y))) + 1
	if max_scan_radius_tiles > 0:
		radius_tiles = min(radius_tiles, max_scan_radius_tiles)

	var min_x: int = center_cell.x - radius_tiles
	var max_x: int = center_cell.x + radius_tiles
	var min_y: int = center_cell.y - radius_tiles
	var max_y: int = center_cell.y + radius_tiles

	var copied := 0
	var had_tile := 0
	var passed := 0

	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			var src_cell := Vector2i(x, y)

			var source_id: int = src.get_cell_source_id(src_cell)
			if source_id == -1:
				continue
			had_tile += 1

			# test SRC cell center in WORLD coords against collider circle
			var cell_world: Vector2 = src.to_global(src.map_to_local(src_cell) + tile_size * 0.5)
			if not _point_inside_zone_circle(cell_world):
				continue
			passed += 1

			# same TileMap grid -> direct copy, no offset
			var dst_cell: Vector2i = src_cell
			new_set[dst_cell] = true

			if not old_set.has(dst_cell):
				var atlas: Vector2i = src.get_cell_atlas_coords(src_cell)
				var alt: int = src.get_cell_alternative_tile(src_cell)
				dst.set_cell(dst_cell, source_id, atlas, alt)
				copied += 1

	for c in old_set.keys():
		if not new_set.has(c):
			dst.erase_cell(c)

	_revealed[dict_key] = new_set

	if debug_logs:
		print(prefix, " idx=", idx,
			" radius_px=", radius_px,
			" radius_tiles=", radius_tiles,
			" had_tile=", had_tile,
			" passed=", passed,
			" copied=", copied,
			" visible_now=", new_set.size())

func clear_all() -> void:
	for dict_key: String in _revealed.keys():
		var parts: PackedStringArray = dict_key.split(":")
		if parts.size() != 2:
			continue

		var prefix: String = parts[0]
		var idx: int = int(parts[1])
		var cells: Dictionary = _revealed[dict_key]

		if prefix == "past" and idx < _past_visibles.size():
			var dst_p: TileMapLayer = _past_visibles[idx]
			for c in cells.keys():
				dst_p.erase_cell(c)
		elif prefix == "future" and idx < _future_visibles.size():
			var dst_f: TileMapLayer = _future_visibles[idx]
			for c in cells.keys():
				dst_f.erase_cell(c)

	_revealed.clear()

func _point_inside_zone_circle(world_point: Vector2) -> bool:
	if _cs == null or _cs.shape == null or _cs.disabled:
		return false

	var circle := _cs.shape as CircleShape2D
	if circle == null:
		return false

	var p: Vector2 = _cs.to_local(world_point)

	# include scaling
	var radius_px := _get_circle_radius_px()
	return p.length() <= (radius_px + 0.01)
