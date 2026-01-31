extends Node2D

@export var look_ahead_distance := 20.0
@export var look_ahead_speed := 3.0

@onready var player := get_parent()

var current_offset := Vector2.ZERO

func _physics_process(delta):
	var target_offset := Vector2.ZERO

	if abs(player.velocity.x) > 1.0:
		target_offset.x = sign(player.velocity.x) * look_ahead_distance

	current_offset = current_offset.lerp(target_offset, look_ahead_speed * delta)
	global_position = player.global_position + current_offset
