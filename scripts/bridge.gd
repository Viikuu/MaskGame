extends Node
class_name Bridge

enum BridgeState { OPEN, CLOSE }

var current_state = BridgeState.OPEN

func _ready():
	$Interactable.interacted.connect(on_bridge_interacted)

func can_interact():
	return false
	
func on_bridge_interacted():
	current_state = BridgeState.CLOSE
	$Sprite2D/PivotAnimation.play("close")
	$BridgeClosingTimer.start()
	

func _on_bridge_closing_timer_timeout() -> void:
	$CollisionShapeOpened.disabled = true
	$CollisionShapeClosed.disabled = false
	
