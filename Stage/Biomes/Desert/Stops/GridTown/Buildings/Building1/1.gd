extends Node3D

func _ready() -> void:
	Global.level.get_node("LevelGen").sewer_entrances.append($SewerEntrance)
