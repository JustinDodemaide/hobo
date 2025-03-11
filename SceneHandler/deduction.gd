extends State

@export var parent:Node
var required_sustenance = 1

func enter(_previous_state: String, _data := {}) -> void:
	parent.distance_to_checkpoint -= 1
	if parent.distance_to_checkpoint <= 0:
		checkpoint_reached()
	else:
		transition("Level")

func new_checkpoint():
	parent.upcoming_checkpoint = parent.checkpoints.pick_random()
	parent.distance_to_checkpoint = 3
	print(parent.upcoming_checkpoint.description)

func checkpoint_reached():
	var car_manifest = $"../TrainCar".get_manifest()
	for item in car_manifest.level_items:
		var category = item.item.category()
		if category == parent.upcoming_checkpoint.required_resource_category:
			parent.upcoming_checkpoint.required_resource_category -= item.item.resource_value()
			item.queue_free()
			if parent.upcoming_checkpoint.required_resource_category <= 0:
				new_checkpoint()
				transition("Level")
				break
	parent.lose()

# take resources or give consequences from last sub-challenge, give new sub-challenge
# decrease checkpoint distance
# if at checkpoint, take resources or give consequence (losing i guess), then end
# game or make next checkpoint
