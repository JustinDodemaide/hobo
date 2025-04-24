extends Node

var stage:Stage

func _ready() -> void:
	stage = get_parent().stage
	# Make sure we have a properly initialized stage
	if stage.stops.size() == 0:
		push_error("Stage has no stops! Regenerating...")
		stage.generate()
	
	next_stop()

func next_stop():
	stage.current_stop += 1
	if stage.current_stop >= stage.stops.size() or stage.current_stop >= stage.number_of_stops:
		stage_complete()
		return
	
	print("Loading stop ", stage.current_stop, " of ", stage.stops.size())
	var stop = stage.stops[stage.current_stop].instantiate()
	stop.complete.connect(after_level)
	add_child(stop)

func after_level():
	# deduct resources
	for key in Global.resources:
		Global.resources[key] -= Stage.DEFAULT_RESOURCE_REDUCTION
		if stage.resource_deduction_modifiers.has(key):
			var multiplier = stage.resource_deduction_modifiers[key]
			Global.resources[key] -= Stage.DEFAULT_RESOURCE_REDUCTION * multiplier
	SignalBus.emit_signal("resources_deducted")
	get_parent().train_car.cot.interacted.connect(next_stop)

func stage_complete():
	after_level()
