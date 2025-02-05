extends CharacterBodyStateMachine

func pursue(player:Player) -> void:
	transition("Pursue",{"target":player})
