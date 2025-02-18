extends StateMachine

@export var train_car:TrainCar

# Train car only exists in level
# Wouldnt it be cooler to have a constant "home base"?
# So train car exists in several scenes
# Could create a new one each time, but it would be better to just retain it

func _ready() -> void:
	Global.scene_handler = self
	
	state = initial_state
	transition(state.name)
