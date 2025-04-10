extends Node3D
class_name MapNodeIcon

var node

var area_hovered:bool = false
signal hovered(icon:MapNodeIcon)
signal selected(icon:MapNodeIcon)

func added_to_map(node, map):
	hovered.connect(map.icon_hovered)
	selected.connect(map.icon_selected)

func _input(event: InputEvent) -> void:
	if area_hovered and event.is_action_pressed("LeftClick"):
		emit_signal("selected",self)

func _on_area_3d_mouse_entered() -> void:
	area_hovered = true
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector3(1.5,1.5,1.5),0.5).set_trans(Tween.TRANS_ELASTIC)
	emit_signal("hovered",self)

func _on_area_3d_mouse_exited() -> void:
	area_hovered = false
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector3(1,1,1),0.5).set_trans(Tween.TRANS_ELASTIC)
