extends Node3D

var checking_players:bool

func start():
	Global.scene_handler.train_car.global_position = $Train.get_node("CarMarker").global_position
	Global.scene_handler.train_car.reparent($Train)
	var tween = create_tween()
	tween.finished.connect(stopped_at_station)
	tween.tween_property($Train,"position",$Middle.position, Global.level.pullup_time).set_trans(Tween.TRANS_QUAD)

func stopped_at_station():
	Global.scene_handler.train_car.open_door()
	Global.level.timer.timeout.connect(leaving)
	Global.level.timer.start(Global.level.level_time)

func leaving():
	var tween = create_tween()
	tween.finished.connect(complete)
	tween.tween_property($Train,"position",$End.position, Global.level.leave_time).set_trans(Tween.TRANS_QUAD)
	
func complete():
	Global.scene_handler.transition("BetweenStops")
