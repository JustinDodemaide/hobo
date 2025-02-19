extends State

func enter(_previous_state: String, _data := {}) -> void:
	add_child(load("res://DeductionScreen/DeductionScreen.tscn").instantiate())
	
	var total_food:int
	var info = Global.scene_handler.train_car.get_info()
	for item in info.items:
		total_food += item.nutritional_value() * info.items[item]
	$PanelContainer/VBoxContainer/Label.text += str(total_food)
