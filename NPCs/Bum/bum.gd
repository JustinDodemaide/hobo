extends CharacterBodyStateMachine

# make this guy like the pentagon thief. if the player has something of value
# they chase them down and steal it


func alerted_by(player:Player) -> void:
	var desired_item = get_desired_item(player)
	if desired_item == null:
		return
	transition("Pursue", {"target":player})

func get_desired_item(player:Player) -> Dictionary:
	var desired_item_info:Dictionary = {
		"item":null,
		"value":0
	}
	# check player inventory
	var player_inventory = player.get_node("Camera3D").get_node("PlayerInventoryHandler").inventory
	var index = 0
	for item in player_inventory:
		if item: # dont have a way of tracking item value right now
			desired_item_info.item = item
			
	return desired_item_info
