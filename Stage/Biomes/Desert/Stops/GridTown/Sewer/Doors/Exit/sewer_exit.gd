extends Node3D

var entrance

func _on_interactable_area_interacted(who: Variant) -> void:
	if who is not Player:
		return
	who.global_position = entrance.global_position
