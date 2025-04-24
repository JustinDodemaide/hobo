extends Node3D

@export var accepted_category:Item.RESOURCE_CATEGORIES = Item.RESOURCE_CATEGORIES.FUEL

func _ready() -> void:
	return
	deactivate()
	SignalBus.out_of_level.connect(stop_reached)
	SignalBus.preparing_for_level.connect(deactivate)

func stop_reached():
	var checkpoint = Global.scene_handler.checkpoint
	var challenge = Global.scene_handler.challenge
	if accepted_category == challenge.category:
		activate()
		return
	if Global.scene_handler.distance_to_checkpoint != 0:
		return
	if accepted_category == checkpoint.category:
		activate()

func activate():
	var cat1 = Global.scene_handler.checkpoint.category
	var cat2 = Global.scene_handler.challenge.category
	if accepted_category == cat1 or accepted_category == cat2:
		$InteractableArea.enable()

func deactivate():
	$InteractableArea.disable()

func _on_interactable_area_interacted(who: Variant) -> void:
	if who is not Player:
		return
	if who.held_item == null:
		return
	if who.held_item.category() != accepted_category:
		return
	var item = who.held_item
	who.inventory_component.remove_item()
	SignalBus.emit_signal("item_deposited",item)
	if Global.resources[accepted_category] >= Global.MAX_RESOURCES:
		deactivate()
