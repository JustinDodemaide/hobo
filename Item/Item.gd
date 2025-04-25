class_name Item

enum RESOURCE_CATEGORIES {FUEL, RATIONS, HYDRATION, MONEY}

func item_name() -> String:
	return "Item"

func image_path() -> String:
	return "res://test_test.png"

func category() -> RESOURCE_CATEGORIES:
	return -1

func resource_value() -> int:
	return 1

func picked_up(_by:Player) -> void:
	# In case we want the item to do something upon being picked up
	# YAGNI
	pass

func dropped(_by:Player) -> void:
	pass

func use(_user:Player) -> void:
	if is_consumable():
		consumed(_user)

func use_alternate(_user:Player) -> void:
	pass

#region Consumption
func is_consumable() -> bool:
	return false

func consumed(_by:Player) -> void:
	pass

# How many levels until the food spoils
func lifetime() -> int:
	return 0
#endregion
