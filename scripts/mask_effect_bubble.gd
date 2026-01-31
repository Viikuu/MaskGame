#extends Area2D
#class_name RevealZone
#
#enum Mode { NOW, PAST, FUTURE }
#
#@export var mode: Mode = Mode.NOW
#@export var active: bool = true
#
## Scan size around the player in tile cells (should cover your zone radius)
#@export var candidate_radius_tiles: int = 8
#
## Drag any TileMapLayer that shares the same grid (usually your base layer)
#@export var reference_layer: TileMapLayer
#
#var _past_sources: Array[TileMapLayer] = []
#var _past_visibles: Array[TileMapLayer] = []
#var _future_sources: Array[TileMapLayer] = []
#var _future_visibles: Array[TileMapLayer] = []
#
## key = "past:idx" or "future:idx" -> Dictionary(cell -> true)
#var _revealed: Dictionary[String, Dictionary] = {}
#
#var _last_center_cell: Vector2i = Vector2i(999999, 999999)
#
#func _ready() -> void:
	#_collect_layers()
#
#func _collect_layers() -> void:
	#_past_sources = _collect_sorted("past_source")
	#_past_visibles = _collect_sorted("past_visible")
	#_future_sources = _collect_sorted("future_source")
	#_future_visibles = _collect_sorted("future_visible")
#
#func _collect_sorted(group_name: String) -> Array[TileMapLayer]:
	#var arr: Array[TileMapLayer] = []
	#for n in get_tree().get_nodes_in_group(group_name):
		#if n is TileMapLayer:
			#arr.append(n)
#
	## Sort by z_index, then name for stable ordering
	#arr.sort_custom(func(a: TileMapLayer, b: TileMapLayer) -> bool:
		#if a.z_index == b.z_index:
			#return a.name < b.name
		#return a.z_index < b.z_index
	#)
#
	#return arr
#
#func set_mode(new_mode: Mode) -> void:
	#if mode == new_mode:
		#return
	#clear_all() # wipe old overlay tiles
	#mode = new_mode
	#_last_center_cell = Vector2i(999999, 999999)
#
#func set_active(value: bool) -> void:
	#if active == value:
		#return
	#active = value
	#if not active:
		#clear_all()
	#_last_center_cell = Vector2i(999999, 999999)
#
#func update_if_needed(player_world_pos: Vector2) -> void:
	#if not active:
		#return
	#if reference_layer == null:
		#return
#
	#if mode == Mode.NOW:
		#return
#
	#var center_cell: Vector2i = reference_layer.local_to_map(reference_layer.to_local(player_world_pos))
	#if center_cell == _last_center_cell:
		#return
	#_last_center_cell = center_cell
#
	#if mode == Mode.PAST:
		#_update_group("past", _past_sources, _past_visibles, center_cell)
	#elif mode == Mode.FUTURE:
		#_update_group("future", _future_sources, _future_visibles, center_cell)
#
#func _update_group(prefix: String, sources: Array[TileMapLayer], visibles: Array[TileMapLayer], center_cell: Vector2i) -> void:
	#var count: int = mini(sources.size(), visibles.size())
	#if count <= 0:
		#return
#
	#for i in range(count):
		#_update_pair(prefix, i, sources[i], visibles[i], center_cell)
#
#func _update_pair(prefix: String, idx: int, src: TileMapLayer, dst: TileMapLayer, center_cell: Vector2i) -> void:
	#var dict_key: String = prefix + ":" + str(idx)
#
	#var old_set: Dictionary
	#if _revealed.has(dict_key):
		#old_set = _revealed[dict_key]
	#else:
		#old_set = {}
		#_revealed[dict_key] = old_set
#
	#var new_set: Dictionary = {}
#
	#var min_x: int = center_cell.x - candidate_radius_tiles
	#var max_x: int = center_cell.x + candidate_radius_tiles
	#var min_y: int = center_cell.y - candidate_radius_tiles
	#var max_y: int = center_cell.y + candidate_radius_tiles
#
	#for x in range(min_x, max_x + 1):
		#for y in range(min_y, max_y + 1):
			#var cell := Vector2i(x, y)
#
			## If no tile in source layer, skip
			#var source_id: int = src.get_cell_source_id(cell)
			#if source_id == -1:
				#continue
#
			## Any-shape test: check cell center overlaps this Area2D
			#var cell_center_world: Vector2 = src.to_global(src.map_to_local(cell))
			#if not _point_inside_this_area(cell_center_world):
				#continue
#
			#new_set[cell] = true
#
			## Newly entered -> copy tile
			#if not old_set.has(cell):
				#var atlas: Vector2i = src.get_cell_atlas_coords(cell)
				#var alt: int = src.get_cell_alternative_tile(cell)
				#dst.set_cell(cell, source_id, atlas, alt)
#
	## Left zone -> erase
	#for c in old_set.keys():
		#if not new_set.has(c):
			#dst.erase_cell(c)
#
	#_revealed[dict_key] = new_set
#
#func clear_all() -> void:
	#for dict_key: String in _revealed.keys():
		#var parts: PackedStringArray = dict_key.split(":")
		#if parts.size() != 2:
			#continue
#
		#var prefix: String = parts[0]
		#var idx: int = int(parts[1])
		#var cells: Dictionary = _revealed[dict_key]
#
		#if prefix == "past" and idx < _past_visibles.size():
			#var dst_p: TileMapLayer = _past_visibles[idx]
			#for c in cells.keys():
				#dst_p.erase_cell(c)
#
		#if prefix == "future" and idx < _future_visibles.size():
			#var dst_f: TileMapLayer = _future_visibles[idx]
			#for c in cells.keys():
				#dst_f.erase_cell(c)
#
	#_revealed.clear()
#
#func _point_inside_this_area(world_point: Vector2) -> bool:
	## IMPORTANT: this Area2D mask must include its own layer.
	#var space := get_world_2d().direct_space_state
	#var params := PhysicsPointQueryParameters2D.new()
	#params.position = world_point
	#params.collide_with_areas = true
	#params.collide_with_bodies = false
	#params.collision_mask = collision_mask
#
	#var hits: Array[Dictionary] = space.intersect_point(params, 16)
	#for h in hits:
		#if h.has("collider") and h["collider"] == self:
			#return true
	#return false
