extends StateMachine

@export var train_car:TrainCar

var checkpoints = [
	Checkpoint.new("Acquire %s of %s", 0, 1)
]

class Checkpoint:
	var description:String
	var required_resource:Item.RESOURCE_CATEGORIES
	var required_amount:int
	
	func _init(_description:String, _required_resource:Item.RESOURCE_CATEGORIES, _required_amount:int) -> void:
		var enum_name = Item.RESOURCE_CATEGORIES.keys()[_required_resource]
		description = _description % [str(_required_amount), enum_name]
		required_resource = _required_resource
		required_amount = _required_amount

func _ready() -> void:
	print(checkpoints[0].description)
	Global.scene_handler = self
	
	state = initial_state
	transition(state.name)

func lose():
	get_tree().quit()
