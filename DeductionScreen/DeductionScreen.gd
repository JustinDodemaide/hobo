extends Control


func _ready() -> void:
	var total_food:int
	var info = Global.scene_handler.train_car.get_info()
	for item in info.items:
		total_food += item.nutritional_value() * info.items[item]
	$PanelContainer/VBoxContainer/Label.text += str(total_food)

func _on_button_pressed() -> void:
	Global.scene_handler.transition("Level")
