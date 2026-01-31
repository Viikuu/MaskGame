extends Node

func _ready() -> void:
	$Lock.unlocked.connect(_on_lock_unlocked)

func _on_lock_unlocked():
	$Sprite2D.play("open")
	$DoorColider.queue_free()
