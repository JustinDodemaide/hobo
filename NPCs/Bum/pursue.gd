extends State

func enter(_previous_state: String, _data := {}) -> void:
	var parent = get_parent()
	parent.track(_data.target)

func exit() -> void:
	var parent = get_parent()
	parent.stop_tracking

func target_reached() -> void:
	transition("Steal")
