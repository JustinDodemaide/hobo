extends Node3D

func _ready() -> void:
	return
	Global.level.get_node("LevelGen").sewer_entrances.append($SewerEntrance)
