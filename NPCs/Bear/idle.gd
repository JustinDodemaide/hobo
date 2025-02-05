extends State

func enter(_previous_state: String, _data := {}) -> void:
	#get_parent().visible = false
	pass

func exit() -> void:
	get_parent().visible = true
