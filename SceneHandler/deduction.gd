extends State

func enter(_previous_state: String, _data := {}) -> void:
	var screen = load("res://DeductionScreen/DeductionScreen.tscn").instantiate()
	add_child(screen)
	
	var total_food:int
	var info = Global.scene_handler.train_car.get_info()
	for item in info.items:
		total_food += item.nutritional_value() * info.items[item]
	screen.label.text += str(total_food)
