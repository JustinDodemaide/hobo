extends Node3D

# make this guy like the pentagon thief. if the player has something of value
# they chase them down and steal it

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_sensors_updated() -> void:
	for player in $Sensors.get_sighted_players:
		for item in player.
