extends CharacterBodyStateMachine

signal destination_reached 

func go_to(destination_node:Marker3D) -> void:
	if not nav:
		nav = get_node("NavigationAgent3D")
	if not state:
		state = $Strolling
	$Strolling.destination = destination_node
	transition("Strolling")
