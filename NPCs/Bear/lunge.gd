extends State

func enter(_previous_state: String, _data := {}) -> void:
	var parent = get_parent()
	parent.moving = false

func exit() -> void:
	pass
