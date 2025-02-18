extends Item

func item_name() -> String:
	return "Bread"

func image_path() -> String:
	return "res://Item/Bread/Bread.png"

func picked_up(_by:Player) -> void:
	pass

func dropped(_by:Player) -> void:
	pass

func nutritional_value() -> int:
	return 1
