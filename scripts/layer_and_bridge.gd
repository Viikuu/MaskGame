extends Node

@export var bridge: Bridge
@export var lever: LeverBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lever.lever_opened.connect(open_bridge)


func open_bridge():
	bridge.on_bridge_interacted()
