extends State

@export var parent:Node

func enter(_previous_state: String, _data := {}) -> void:
	parent.distance_to_checkpoint -= 1
	SignalBus.emit_signal("between_stops")
	var info = check_challenge_requirements()
	if info.was_requirement_met:
		for item in info.items:
			item.queue_free()
	else:
		parent.lose()
	
	if parent.distance_to_checkpoint <= 0:
		var resource_info = check_checkpoint_requirements()
		if resource_info.was_requirement_met:
			for item in resource_info.items:
				item.queue_free()
			parent.new_checkpoint()
			next_level()
		else:
			parent.lose()

func new_checkpoint():
	parent.new_checkpoint()
	parent.distance_to_checkpoint = 3
	print(parent.upcoming_checkpoint.description)
	SignalBus.emit_signal("new_checkpoint")

func check_challenge_requirements() -> Dictionary:
	var info = {"was_requirement_met":false,"items":[]}
	
	# Eventually need to change this to knapsack algo
	var required_category = parent.current_level_challenge.required_resource_category
	var car_manifest = $"../TrainCar".get_manifest()
	for item in car_manifest.level_items:
		info.items.append(item)
		var category = item.item.category()
		if category == required_category:
			var value = item.item.resource_value()
			parent.current_level_challenge.required_amount -= value
			if parent.current_level_challenge.required_amount <= 0:
				info.was_requirement_met = true
				break
	return info

func check_checkpoint_requirements() -> Dictionary:
	var info = {"was_requirement_met":false,"items":[]}
	
	# Eventually need to change this to knapsack algo
	var required_category = parent.upcoming_checkpoint.required_resource_category
	var car_manifest = $"../TrainCar".get_manifest()
	for item in car_manifest.level_items:
		info.items.append(item)
		var category = item.item.category()
		if category == required_category:
			var value = item.item.resource_value()
			parent.upcoming_checkpoint.required_amount -= value
			if parent.upcoming_checkpoint.required_amount <= 0:
				info.was_requirement_met = true
				break
	return info

func next_level():
	parent.new_level_challenge()
	transition("Level")

# take resources or give consequences from last sub-challenge, give new sub-challenge
# decrease checkpoint distance
# if at checkpoint, take resources or give consequence (losing i guess), then end
# game or make next checkpoint
