extends StateMachine

@export var train_car:TrainCar

func _ready() -> void:
	Global.scene_handler = self
	
	state = initial_state
	transition(state.name)

func lose():
	get_tree().quit()
