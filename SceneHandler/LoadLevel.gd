extends State

enum {
	GRID_TOWN,
	}

const PATHS = {
	GRID_TOWN: "res://Levels/GridTown/Level_GridTown.tscn",
	
}

var level

func enter(_previous_state: String, _data := {}) -> void:
	level = load(PATHS[GRID_TOWN]).instantiate()
	add_child(level)
	# $"../TrainCar".get_node("Cot").interacted.connect(cot_interacted_with)

func exit() -> void:
	if !level:
		return
	# $"../TrainCar".get_node("Cot").interacted.disconnect(cot_interacted_with)
	Global.level = null
	Global.scene_handler.train_car.reparent(Global.scene_handler)
	level.queue_free()
