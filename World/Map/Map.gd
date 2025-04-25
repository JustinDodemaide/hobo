extends Node3D
class_name WorldMap

var _world

signal selection_made(icon)

func activate():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = true
	$Camera3D.current = true
	prep_choices()

func deactivate():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false
	$Camera3D.current = false
	Global.enable_players()

@onready var vert = $VBoxContainer
@onready var template = $Sprite3D
var icons = {}
func generate(world:World):
	_world = world
	var icon_packed_scene = load("res://World/Map/MapEventIcon.tscn")
	var canvas_size = $MeshInstance3D.mesh.size
	var vertical_increment = canvas_size.y / world.nodes.size()
	var v_pos = vertical_increment
	for depth in world.nodes.size():
		var nodes = world.nodes[depth]
		var horizontal_increment = canvas_size.x / (world.nodes[depth].size() + 1)
		var h_pos = horizontal_increment
		for node in nodes:
			var icon = icon_packed_scene.instantiate()
			icon.position = Vector3(h_pos, 0, v_pos)
			icon.added_to_map(node, self)
			add_child(icon)
			icons[node] = icon
			h_pos += horizontal_increment
		v_pos += vertical_increment
	
	var line_packed_scene = load("res://World/Map/Line/Line.tscn")
	for level in world.nodes:
		for node in world.nodes[level]:
			for connected_node in node.branches:
				var line = line_packed_scene.instantiate()
				line.connect_icons(icons[node], icons[connected_node])
				line.scale /= 2 # Changing the scale in the scene didnt work for some reason
				add_child(line)

func focus(icon:MapNodeIcon):
	var tween = create_tween()
	var final_pos = Vector3(icon.position.x, $Camera3D.position.y, icon.position.z - 1)
	tween.tween_property($Camera3D,"position",final_pos,1).set_trans(Tween.TRANS_CUBIC)

func icon_hovered(icon):
	focus(icon)

func icon_selected(icon):
	emit_signal("selection_made",icon)

var current_depth:int = 0
func prep_choices():
	for node in _world.nodes[current_depth]:
		var icon = icons[node]
		icon.deactivate()
	var next_depth = current_depth + 1
	for node in _world.nodes[next_depth]:
		var icon = icons[node]
		icon.activate()

func choice_made(choice:MapNodeIcon):
	# move train figurine
	for node in _world[current_depth]:
		var icon = icons[node]
		icon.deactivate()
	current_depth += 1

#region Camera
var camera_speed = 0.1
var camera_moving:bool = false
var up:bool = true
var upper_bound = 1
var lower_bound = -1.0
var time_held = 0.0
func _process(delta: float) -> void:
	if not camera_moving:
		return
	if $Camera3D.position.z >= upper_bound and up:
		return
	if $Camera3D.position.z <= lower_bound and not up:
		return
	time_held += delta
	
	var direction = -1
	if up:
		direction = 1
	var dx = camera_speed * time_held
	$Camera3D.position.z += -(cos(PI * dx) - 1) / 4 * direction

func _on_up_mouse_entered() -> void:
	camera_moving = true
	up = true

func _on_up_mouse_exited() -> void:
	camera_moving = false
	time_held = 0

func _on_down_mouse_entered() -> void:
	camera_moving = true
	up = false

func _on_down_mouse_exited() -> void:
	camera_moving = false
	time_held = 0
#endregion
