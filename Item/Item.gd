class_name Item

func item_name() -> String:
	return "Item"

func image_path() -> String:
	return "res://test_test.png"

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

func sustenance_value() -> int:
	return 0

func consumed(_by:Player) -> void:
	if Global.scene_handler.state.name == "BetweenStops":
		Global.scene_handler.state.item_consumed(self)
		_by.remove_item()

# How many levels until the food spoils
func lifetime() -> int:
	return 0
#endregion
