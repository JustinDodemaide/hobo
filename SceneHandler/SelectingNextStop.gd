extends State

func enter(_previous_state: String, _data := {}) -> void:
	# make a new map if at the end of the current one, etc etc
	#for player in Global.players:
	#	player.disable()
	$"../Map".activate()

func exit() -> void:
	pass
