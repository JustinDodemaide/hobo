extends Node3D

@export var entry_point:Marker3D

func _ready() -> void:
	if entry_point == null:
		push_error("no entry point assigned for interior")


func _on_interactable_area_interacted(who: Variant) -> void:
	who.global_position = entry_point.global_position
