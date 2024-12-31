class_name Item

func item_name() -> String:
	return "Item"

func image_path() -> String:
	return "res://Item/Coffee/Coffee.png"

func picked_up(by:Player) -> void:
	# In case we want the item to do something upon being picked up
	# YAGNI
	pass

func dropped(by:Player) -> void:
	pass
