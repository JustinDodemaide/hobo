extends State

var biome

class MapNode:
	const EVENTS = ["idk"]
	var event:String
	var branches = []
	
	func _init(_event:String = "random") -> void:
		if _event == "random":
			event = EVENTS.pick_random()

func _ready() -> void:
	map = {0: [MapNode.new()]}
	_map(map[0][0],0)
	graphic()

var map = {}
var max_depth = 3
func _map(current_node,depth):
	if depth == max_depth:
		return
	randomize()
	var num_branches = randi_range(1,2)
	# First, check if there are any nodes already on the next level that we can connect to
	if map.has(depth + 1):
		#if randi_range(0,1) == 0:
		current_node.branches.append(map[depth + 1].back())
		num_branches -= 1
	else:
		map[depth + 1] = []
	
	# Then make new nodes and add them to the next level
	for branch in num_branches:
		var new_node = MapNode.new()
		current_node.branches.append(new_node)
		map[depth + 1].append(new_node)
	
	for node in current_node.branches:
		_map(node, depth + 1)

@onready var vert = $VBoxContainer
@onready var template = $Sprite3D
func graphic():
	var icons = {}
	var icon_packed_scene = load("res://Map/MapEventIcon.tscn")
	var canvas_size = $MeshInstance3D.mesh.size
	var vertical_increment = (canvas_size.y / map.size()) / 1.5 * 1.5
	var v_pos = vertical_increment
	for depth in map.size():
		var nodes = map[depth]
		var horizontal_increment = (canvas_size.x / nodes.size()) / 1.5
		var h_pos = (horizontal_increment / 2) * 1.5
		for node in nodes:
			var icon = icon_packed_scene.instantiate()
			icon.position = Vector3(h_pos, 0, v_pos)
			icon.added_to_map(node, self)
			add_child(icon)
			icons[node] = icon
			h_pos += horizontal_increment
		v_pos += vertical_increment
	
	var line_packed_scene = load("res://Map/Line/Line.tscn")
	for level in map:
		for node in map[level]:
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
	pass

func icon_selected(icon):
	focus(icon)
