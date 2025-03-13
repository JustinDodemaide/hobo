extends Node3D

var checking_players:bool
const START_TIME:float = 10#20
const STOP_TIME:float = 1#100
const LEAVING_TIME:float = 10#20

func start():
	Global.scene_handler.train_car.global_position = $Train.get_node("CarMarker").global_position
	Global.scene_handler.train_car.reparent($Train)
	var tween = create_tween()
	tween.finished.connect(stopped_at_station)
	tween.tween_property($Train,"position",$Middle.position, START_TIME).set_trans(Tween.TRANS_QUAD)

func stopped_at_station():
	Global.scene_handler.train_car.open_door()
	Global.level.timer.timeout.connect(leaving)
	Global.level.timer.start(STOP_TIME)

func leaving():
	var tween = create_tween()
	tween.finished.connect(complete)
	tween.tween_property($Train,"position",$End.position, LEAVING_TIME).set_trans(Tween.TRANS_QUAD)
	
func complete():
	Global.scene_handler.transition("BetweenStops")
