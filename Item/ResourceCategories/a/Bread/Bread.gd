extends Item

func item_name() -> String:
	return "Bread"

func image_path() -> String:
	return "res://Item/ResourceCategories/a/Bread/Bread.png"

func category() -> RESOURCE_CATEGORIES:
	return RESOURCE_CATEGORIES.FUEL
