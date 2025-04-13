extends Node3D
class_name Cot

signal interacted

func _on_interactable_area_interacted(who: Variant) -> void:
	emit_signal("interacted")
