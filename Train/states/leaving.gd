extends State

var parent
func update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	var time = 25.0
	
	$"../TrainCar".close_door()
	for player:Player in $"../TrainCar".get_players():
		player.reparent($"..")
	#for player in Global.players:
	#	player.ui.fade_out(time/2 )
	
	var parent = get_parent()
	var tween = create_tween()
	tween.tween_property(parent,"progress_ratio",1.0,time).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	#transition("PullingUp")
	Global.scene_handler.transition("Deduction")


func exit() -> void:
	pass
