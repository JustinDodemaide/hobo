extends State

func enter(_previous_state: String, _data := {}) -> void:
	var parent = get_parent()
	parent.moving = false
	if parent.tracking_target.current_health > 0:
		transition("Pursue",{"target":parent.tracking_target})

func exit() -> void:
	pass
