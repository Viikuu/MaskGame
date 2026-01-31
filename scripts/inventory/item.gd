class_name Item

var in_hand_texture: Texture2D

func _init():
	pass

func use():
	pass
	
class LeverHandle extends Item:
	func _init():
		super._init()
		in_hand_texture = load("res://art_me/Lever_Small.png")
	
	func use():
		print("lever handle has been used")

class Key extends Item:
	func _init():
		super._init()
		in_hand_texture = load("res://art_me/KeySmall.png")
	
	func use():
		print("key has been used")
