extends Node3D
class_name MapNodeIcon

var stage:Stage

var _scale

var area_hovered:bool = false
signal hovered(icon:MapNodeIcon)
signal selected(icon:MapNodeIcon)

func _ready() -> void:
	stage = load("res://Stage/Stage.gd").new()
	stage.generate()
	_scale = $Sprite3D.scale

func added_to_map(node, map):
	hovered.connect(map.icon_hovered)
	selected.connect(map.icon_selected)

func _input(event: InputEvent) -> void:
	if area_hovered and event.is_action_pressed("LeftClick"):
		emit_signal("selected",self)

func _on_area_3d_mouse_entered() -> void:
	area_hovered = true
	var tween = create_tween()
	tween.tween_property($Sprite3D,"scale",scale * 2,0.5).set_trans(Tween.TRANS_ELASTIC)
	emit_signal("hovered",self)
	print("enter")

func _on_area_3d_mouse_exited() -> void:
	area_hovered = false
	var tween = create_tween()
	tween.tween_property($Sprite3D,"scale",scale * 1.5,0.5).set_trans(Tween.TRANS_ELASTIC)

func activate():
	var light_tween = create_tween()
	light_tween.tween_property($OmniLight3D,"light_energy",0.5,2.0).set_trans(Tween.TRANS_CUBIC)
	
	$Area3D/CollisionShape3D.disabled = false

func deactivate():
	#var burnout_tween = create_tween()
	#burnout_tween.tween_property($OmniLight3D,"light_energy",2.0,1.0)
	#await burnout_tween.finished
	var dim_tween = create_tween()
	dim_tween.tween_property($OmniLight3D,"light_energy",0.0,0.1)
	$Sprite3D.modulate = Color(0,0,0)
