extends StateMachine

@export var train_car:TrainCar

var upcoming_checkpoint:ResourceRequirement
var distance_to_checkpoint:int = 3
var checkpoints = [
	ResourceRequirement.new(1, 1)
]

var current_level_challenge
var level_challenges = [
	ResourceRequirement.new(randi_range(0,Item.RESOURCE_CATEGORIES.keys().size()),randi_range(1,3))
]

class ResourceRequirement:
	var description:String
	var required_resource_category:Item.RESOURCE_CATEGORIES
	var required_amount:int
	
	func _init(_required_resource_category:Item.RESOURCE_CATEGORIES, _required_amount:int, _description:String="Acquire %s of %s") -> void:
		var enum_name = Item.RESOURCE_CATEGORIES.keys()[_required_resource_category]
		description = _description % [str(_required_amount), enum_name]
		required_resource_category = _required_resource_category
		required_amount = _required_amount
	
	#func make_level_challenge() -> void:
		#required_resource_category = Item.RESOURCE_CATEGORIES.keys().pick_random()
		#required_amount = randi_range(1,3)
		#
		#var enum_name = Item.RESOURCE_CATEGORIES.keys()[required_resource_category]
		#description = "Acquire %s of %s" % [str(required_amount), enum_name]

func _ready() -> void:
	Global.scene_handler = self
	
	new_checkpoint()
	new_level_challenge()
	
	state = initial_state
	transition(state.name)

func lose():
	get_tree().quit()

func new_checkpoint():
	upcoming_checkpoint = checkpoints.pick_random()
	distance_to_checkpoint = 3
	SignalBus.emit_signal("new_checkpoint_assigned")

func new_level_challenge():
	current_level_challenge = level_challenges.pick_random()
	SignalBus.emit_signal("new_level_challenged_assigned")
