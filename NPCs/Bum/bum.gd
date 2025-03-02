extends CharacterBodyStateMachine

# make this guy like the pentagon thief. if the player has something of value
# they chase them down and steal it

var spawn
var held_item:Item

func alerted_by(player:Player) -> void:
	spawn = global_position
	for space in player.inventory:
		if space != null:
			transition("Pursue", {"target":player})

func hold_item(item):
	held_item = item
	$Item.texture = load(item.image_path())
