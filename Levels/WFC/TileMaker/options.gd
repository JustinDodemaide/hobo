extends PanelContainer

@export var option_buttons:Control

func init(list):
	for button in option_buttons.get_children():
		for option in list:
			button.add_item(option.item_name)

func _on_add_pressed() -> void:
	option_buttons.add_child(option_buttons.get_children().front().duplicate())

# need to check if the old name is already in the options. if it is, just change the option to the new name.
# If its not, add it as an option.
func update_options(from,to):
	var names = []
	for button in option_buttons.get_children():
		for index in button.item_count:
			if from == button.get_item_text(index):
				button.set_item_text(index, to)
				return
		button.add_item(to)

func get_options():
	var options = []
	for button in option_buttons.get_children():
		for index in button.item_count:
			options.append(button.get_item_text(index))
	return options
