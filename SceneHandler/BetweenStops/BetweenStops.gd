extends State

# The cot is the physical vassal of BetweenStops. They are tightly coupled
var cot:InteractableArea

func enter(_previous_state: String, _data := {}) -> void:
	cot = $"../TrainCar".get_node("Cot").get_node("InteractableArea")
	cot.interacted.connect(cot_interacted_with)
	cot.enable()

func exit() -> void:
	cot.interacted.connect(cot_interacted_with)
	cot.disable()

func cot_interacted_with(who:Variant) -> void:
	# check stop requirements
	who.disable()
	transition("SelectingNextStop")
