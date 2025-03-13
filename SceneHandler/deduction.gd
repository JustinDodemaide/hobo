extends State

@export var parent:Node

var challenge
var challenge_needs_to_be_completed:bool = true # Always needs to be true but that could change in the future
var challenge_completed:bool = false

var checkpoint
var checkpoint_needs_to_be_completed:bool = false
var checkpoint_completed:bool = false

func enter(_previous_state: String, _data := {}) -> void:
	# The players have to manually choose which items to give
	parent.distance_to_checkpoint -= 1
	
	challenge = parent.challenge
	checkpoint = parent.checkpoint
	SignalBus.emit_signal("out_of_level")
	SignalBus.continue_button_pressed.connect(check)
	
	if parent.distance_to_checkpoint == 0:
		checkpoint_needs_to_be_completed = true
	challenge_needs_to_be_completed = true
	
	if challenge_needs_to_be_completed:
		SignalBus.item_deposited.connect(put_item_toward_challenge)
	if checkpoint_needs_to_be_completed:
		SignalBus.item_deposited.connect(put_item_toward_checkpoint)

func put_item_toward_challenge(item):
	if item.category() != challenge.category:
		return
	challenge.required_amount -= item.resource_value()
	if challenge.required_amount <= 0:
		challenge_completed = true

func put_item_toward_checkpoint(item):
	if item.category() != checkpoint.category:
		return
	checkpoint.required_amount -= item.resource_value()
	if checkpoint.required_amount <= 0:
		checkpoint_completed = true

func check_completion() -> bool:
	# Check challenge completion if required
	if challenge_needs_to_be_completed and not challenge_completed:
		return false
		
	# Check checkpoint completion if required
	if checkpoint_needs_to_be_completed and not checkpoint_completed:
		return false
		
	# If we got here, all required elements are complete
	return true

func check_items():
	# Not proud
	# Doesn't work anyway
	var has_challenge_items:bool = false
	var has_checkpoint_items:bool = false
	for child in $"../TrainCar".get_children():
		if child is LevelItem:
			var category = child.item.category()
			var value = child.item.resource_value()
			if challenge_needs_to_be_completed:
				if not challenge_completed:
					if category == challenge.category:
						if value >= challenge.required_amount:
							has_challenge_items = true
			if checkpoint_needs_to_be_completed:
				if not checkpoint_completed:
					if category == checkpoint.category:
						if value >= checkpoint.required_amount:
							has_checkpoint_items = true
		if child is Player:
			for item in child.inventory_component.inventory:
				if item != null:
					var category = item.category()
					var value = item.resource_value()
					if challenge_needs_to_be_completed:
						if not challenge_completed:
							if category == challenge.category:
								if value >= challenge.required_amount:
									has_challenge_items = true
					if checkpoint_needs_to_be_completed:
						if not checkpoint_completed:
							if category == checkpoint.category:
								if value >= checkpoint.required_amount:
									has_checkpoint_items = true
	if has_challenge_items and has_checkpoint_items:
		return true
	else:
		return false

func check():
	var requirements_met = check_completion()
	if requirements_met:
		move_forward()
	else:
		parent.lose()

	return
	var items_available = check_items()
	
	# Still have more items to deposit, wait a bit
	if items_available and not requirements_met:
		return
	# Out of items and requirements not met, lose
	if not items_available and not requirements_met:
		parent.lose()
	# Used last item to meet requirements. Doesn't do anything but phew close call
	if not items_available and requirements_met:
		print("Close call!")

func move_forward():
	parent.new_challenge()
	if checkpoint_completed:
		parent.new_checkpoint()
	
	# challenge_needs_to_be_completed = false
	challenge_completed = false
	
	checkpoint_needs_to_be_completed = false
	checkpoint_completed = false
	
	transition("Level")
