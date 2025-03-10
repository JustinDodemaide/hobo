extends Node

@export var player:Player

@export var interactable_cast:RayCast3D
var hovered_interactable:InteractableArea

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		if hovered_interactable:
			hovered_interactable.interact_with(player)
			return

func handle_interactable():
	var collider = $Camera3D/InteractableRayCast.get_collider()
	if collider is not InteractableArea:
		if hovered_interactable:
			hovered_interactable = null
			player.ui.interactable_unhovered()
			return
	if collider is InteractableArea:
		hovered_interactable = collider
		player.ui.interactable_hovered()
