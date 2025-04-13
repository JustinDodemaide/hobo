extends Node

var map

func _ready() -> void:
	map = get_parent().world.get_map()
	map.global_position = Vector3(-100,-100,-100)
	add_sibling(map)
	map.selection_made.connect(selection_made)
	map.activate()

func selection_made(icon):
	get_parent().stage = icon.stage
	map.deactivate()
	add_sibling(load("res://GameLoop/StageHandler.tscn").instantiate())
	queue_free()
