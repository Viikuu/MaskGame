class_name Item

func _init():
	pass

func use():
	pass
	
class LeverHandle extends Item:
	func use():
		print("lever handle has been used")

class Key extends Item:
	func use():
		print("key has been used")
