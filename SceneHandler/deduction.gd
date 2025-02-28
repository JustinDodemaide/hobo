extends State

var required_sustenance = 1
var screen

func enter(_previous_state: String, _data := {}) -> void:
	var total_food:int
	var info = Global.scene_handler.train_car.get_info()
	# Also need to check player's inventories
	if info.players.is_empty():
		get_parent().lose()
	for item in info.items:
		total_food += item.sustenance_value() * info.items[item]
	if total_food < required_sustenance:
		get_parent().lose()

	screen = load("res://DeductionScreen/DeductionScreen.tscn").instantiate()
	add_child(screen)
	screen.set_text(required_sustenance)

func item_consumed(item:Item) -> void:
	required_sustenance -= item.sustenance_value()
	if required_sustenance <= 0:
		screen.queue_free()
		transition("Level")
	else:
		screen.set_text(required_sustenance)
