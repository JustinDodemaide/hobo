extends Node3D

var exit

func _on_interactable_area_interacted(who: Variant) -> void:
	if who is not Player:
		return
	who.global_position = exit.global_position
