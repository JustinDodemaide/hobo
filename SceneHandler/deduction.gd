extends State

func enter(_previous_state: String, _data := {}) -> void:
	add_child(load("res://DeductionScreen/DeductionScreen.tscn").instantiate())
	
