extends Node3D

func open_door() -> void:
	var tween = create_tween()
	var new_pos = Vector3(2,2,-2)
	tween.tween_property($Door, "position", new_pos, 3.0).set_ease(Tween.EASE_OUT)

func close_door() -> void:
	var tween = create_tween()
	var new_pos = Vector3(2,2,2)
	tween.tween_property($Door, "position", new_pos, 3.0).set_ease(Tween.EASE_OUT)

func get_players() -> Array[Player]:
	var players:Array[Player] = []
	for area in $Area3D.get_overlapping_areas():
		var parent = area.get_parent()
		if parent is Player:
			players.append(parent)
	return players

func _on_area_3d_area_entered(area: Area3D) -> void:
	var parent = area.get_parent()
	if parent is Player:
		parent.reparent(get_parent())
	if parent is LevelItem:
		parent.reparent(self)

func _on_area_3d_area_exited(area: Area3D) -> void:
	var parent = area.get_parent()
	if parent is Player:
		parent.reparent(Global.level)
