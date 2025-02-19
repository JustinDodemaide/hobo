class_name Item

func item_name() -> String:
	return "Item"

func image_path() -> String:
	return "res://Item/Coffee/Coffee.png"

func picked_up(_by:Player) -> void:
	# In case we want the item to do something upon being picked up
	# YAGNI
	pass

func dropped(_by:Player) -> void:
	pass

func nutritional_value() -> int:
	return 0

func is_consumable() -> bool:
	return false

func consumed(_by:Player) -> void:
	pass
