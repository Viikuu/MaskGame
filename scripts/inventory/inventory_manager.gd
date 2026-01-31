extends Node

signal item_changed(new_item)

var current_item: Item = null

func add_item(item: Item) -> bool:
	if current_item == null:
		current_item = item
		item_changed.emit(current_item)
		return true
	else:
		return false
		
func use_item():
	current_item.use()
	current_item = null
	item_changed.emit(current_item)
	
