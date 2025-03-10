extends Item

func item_name() -> String:
	return "Bread"

func image_path() -> String:
	return "res://Item/Bread/Bread.png"

func sustenance_value() -> int:
	return 1

func is_consumable() -> bool:
	return true
