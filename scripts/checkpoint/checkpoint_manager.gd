extends Node

var current_checkpoint: Checkpoint

class Checkpoint:
	var respawn: Vector2
	func _init(respawn_point: Vector2):
		respawn = respawn_point

func set_checkpoint(checkpoint: Checkpoint):
	current_checkpoint = checkpoint
	
func return_to_last_checkout(player: Player):
	player.global_position = current_checkpoint.respawn
