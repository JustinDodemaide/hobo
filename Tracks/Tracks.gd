extends Node3D

var checking_players:bool

func start():
	Global.scene_handler.train_car.global_position = $Train.get_node("CarMarker").global_position
	Global.scene_handler.train_car.reparent($Train)
	var tween = create_tween()
	tween.finished.connect(stopped_at_station)
	tween.tween_property($Train,"position",$Middle.position,10).set_trans(Tween.TRANS_QUAD)

func stopped_at_station():
	Global.scene_handler.train_car.open_door()
	var tween = create_tween()
	tween.finished.connect(leaving)
	tween.tween_interval(25)

func leaving():
	var tween = create_tween()
	tween.finished.connect(complete)
	tween.tween_property($Train,"position",$End.position,10).set_trans(Tween.TRANS_QUAD)
	
func complete():
	Global.scene_handler.transition("Deduction")
