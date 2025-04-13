extends Node

var stage:Stage

func _ready() -> void:
	stage = get_parent().stage
	next_stop()

func next_stop():
	stage.current_stop += 1
	if stage.current_stop == stage.number_of_stops:
		stage_complete()
		return
	var stop = stage.stops[stage.current_stop].instantiate()
	stop.complete.connect(after_level)
	add_child(stop)

func after_level():
	# deduct resources
	get_parent().train_car.cot.interacted.connect(next_stop)

func stage_complete():
	pass
