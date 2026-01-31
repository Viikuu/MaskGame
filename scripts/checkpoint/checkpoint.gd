extends Node2D

@onready var interactable: Interactable = $Interactable
@onready var cat_sprite: AnimatedSprite2D = $CatSprite

var used = false

@export var is_start_checkpoint = false

func _ready() -> void:
	if is_start_checkpoint:
		CheckpointManager.set_checkpoint(CheckpointManager.Checkpoint.new(
			$RespawnPoint.global_position
		))
		used = true
		queue_free()
	else:
		interactable.interacted.connect(_on_checkpoint_interacted)
	
func can_interact():
	return !used

func _on_checkpoint_interacted():
	print("checkpoint interacted with")
	cat_sprite.play("sit")
	used = true
	CheckpointManager.set_checkpoint(CheckpointManager.Checkpoint.new(
		$RespawnPoint.global_position
	))
