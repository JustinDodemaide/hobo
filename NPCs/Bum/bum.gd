extends Node3D

# make this guy like the pentagon thief. if the player has something of value
# they chase them down and steal it

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_sensors_updated() -> void:
	for player in $Sensors.get_sighted_players:
		var handler = player.get_node("InventoryHandler")
		var inventory = handler.inventory
		var index = 0
		for item in inventory:
			if item:
				break
			index += 1
		handler.drop_item(index)
