extends State

# The cot is the physical vassal of BetweenStops. They are tightly coupled
var cot:InteractableArea

func _ready() -> void:
	await $"../TrainCar".ready
	var scene = $"../TrainCar".get_node("Cot")
	cot = scene.get_node("Cot")
	cot.interacted.connect(cot_interacted_with)

func enter(_previous_state: String, _data := {}) -> void:
	cot.interacted.connect(cot_interacted_with)

func exit() -> void:
	cot.interacted.connect(cot_interacted_with)

func cot_interacted_with(who:Variant) -> void:
	pass
