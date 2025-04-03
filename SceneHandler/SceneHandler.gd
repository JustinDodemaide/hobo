extends StateMachine

@export var train_car:TrainCar

var checkpoint:ResourceRequirement
var distance_to_checkpoint:int
var _at_checkpoint:bool = false

var challenge:ResourceRequirement = ResourceRequirement.new(randi_range(0,Item.RESOURCE_CATEGORIES.keys().size() - 1),randi_range(1,3))
 
var checkpoints = [
	ResourceRequirement.new(1, 1)
]

class ResourceRequirement:
	var completed:bool = false
	var description_template:String
	var category:Item.RESOURCE_CATEGORIES
	var required_amount:int
	
	func _init(_required_resource_category:Item.RESOURCE_CATEGORIES, _required_amount:int, _description:String="Acquire %s of %s") -> void:
		var enum_name = Item.RESOURCE_CATEGORIES.keys()[_required_resource_category]
		description_template = _description
		category = _required_resource_category
		required_amount = _required_amount
	
	func description() -> String:
		return description_template % [str(required_amount), Item.RESOURCE_CATEGORIES.keys()[category]]
	#func make_level_challenge() -> void:
		#required_resource_category = Item.RESOURCE_CATEGORIES.keys().pick_random()
		#required_amount = randi_range(1,3)
		#
		#var enum_name = Item.RESOURCE_CATEGORIES.keys()[required_resource_category]
		#description = "Acquire %s of %s" % [str(required_amount), enum_name]

func _ready() -> void:
	Global.scene_handler = self
	
	new_checkpoint()
	new_challenge()
	
	state = initial_state
	transition(state.name)

func lose():
	get_tree().quit()

func new_checkpoint():
	checkpoint = ResourceRequirement.new(randi_range(0,Item.RESOURCE_CATEGORIES.keys().size() - 1),randi_range(1,3))
	distance_to_checkpoint = 3
	SignalBus.emit_signal("new_checkpoint_assigned")

func new_challenge():
	challenge = ResourceRequirement.new(randi_range(0,Item.RESOURCE_CATEGORIES.keys().size() - 1),randi_range(1,3))
	SignalBus.emit_signal("new_level_challenged_assigned")

# BetweenStops
# Select cot to end BetweenStops
