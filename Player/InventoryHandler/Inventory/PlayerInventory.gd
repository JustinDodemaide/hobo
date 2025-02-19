extends Control

@export var item_prompts:Label

func update(inventory:Array) -> void:
	var inventory_slots = $SlotContainer.get_children()
	var index = 0
	for item in inventory:
		inventory_slots[index].init(item)
		index += 1

func update_prompts(handler):
	if !handler.hovered_item:
		item_prompts.text = ""
		return
	var item = handler.hovered_item.item
	var text:String = handler.PICKUP_INPUT + ": " + item.item_name()
	if item.is_consumable():
		text += "\n" + handler.CONSUME_INPUT + ": Consume"
	item_prompts.text = text
