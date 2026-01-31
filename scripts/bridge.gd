extends Node

enum BridgeState { OPEN, CLOSE }

var current_state = BridgeState.OPEN

func _ready():
	$Interactable.interacted.connect(_on_bridge_interacted)

func can_interact():
	return current_state == BridgeState.OPEN
	
func _on_bridge_interacted():
	current_state = BridgeState.CLOSE
	$Sprite2D/PivotAnimation.play("close")
	$BridgeClosingTimer.start()
	

func _on_bridge_closing_timer_timeout() -> void:
	$CollisionShapeOpened.disabled = true
	$CollisionShapeClosed.disabled = false
