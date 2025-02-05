extends Control

func update(inventory:Array) -> void:
	var inventory_slots = $SlotContainer.get_children()
	var index = 0
	for item in inventory:
		inventory_slots[index].init(item)
		index += 1
