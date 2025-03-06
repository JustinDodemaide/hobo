extends Node3D
class_name InteractableArea

signal interacted(who:Variant)

func interact_with(who:Variant):
	emit_signal("interacted",who)
