extends State

var target:Player
var desired_item:Item

func enter(_previous_state: String, _data := {}) -> void:
	target = _data.target
	get_parent().track(target)

func target_reached():
	# steal then run
	var desired_item = get_desired_item(target)
	if desired_item == null:
		pass
	get_parent().hold_item(desired_item)
	target.remove_item(desired_item)
	target.apply_force_from_position(get_parent().global_position,1)
	transition("Idle")

func exit() -> void:
	var parent = get_parent()
	parent.stop_tracking()

func get_desired_item(player:Player) -> Item:
	var greatest_value = -10000
	var greatest_value_item = null
	for item:Item in player.inventory:
		if not item:
			continue
		if not item.is_consumable():
			continue
		var value = item.sustenance_value()
		if value > greatest_value:
			greatest_value_item = item
			greatest_value = value
	return greatest_value_item
