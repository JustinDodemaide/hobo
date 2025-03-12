extends StateMachine

@export var train_car:TrainCar

var upcoming_checkpoint:Checkpoint
var distance_to_checkpoint:int = 3
var checkpoints = [
	Checkpoint.new("Acquire %s of %s", 1, 1)
]

class Checkpoint:
	var description:String
	var required_resource_category:Item.RESOURCE_CATEGORIES
	var required_amount:int
	
	func _init(_description:String, _required_resource_category:Item.RESOURCE_CATEGORIES, _required_amount:int) -> void:
		var enum_name = Item.RESOURCE_CATEGORIES.keys()[_required_resource_category]
		description = _description % [str(_required_amount), enum_name]
		required_resource_category = _required_resource_category
		required_amount = _required_amount

func _ready() -> void:
	Global.scene_handler = self
	
	$BetweenStops.new_checkpoint()
	
	state = initial_state
	transition(state.name)

func lose():
	get_tree().quit()
