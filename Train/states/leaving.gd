extends State

var parent
func update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	$"../TrainCar".close_door()
	for player:Player in $"../TrainCar".get_players():
		player.reparent($"..")
	
	var parent = get_parent()
	var tween = create_tween()
	tween.tween_property(parent,"progress_ratio",1.0,25).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	transition("PullingUp")

func exit() -> void:
	pass
