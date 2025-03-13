extends Node3D
class_name InteractableArea

signal interacted(who:Variant)

func enable():
	$CollisionShape3D.disabled = false

func disable():
	$CollisionShape3D.disabled = true

func interact_with(who:Variant):
	emit_signal("interacted",who)
