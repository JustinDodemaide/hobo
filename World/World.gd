class_name World

var nodes:Dictionary

var max_depth:int
var depth:int
var node:WorldNode

class WorldNode:
	var stage:Stage
	var branches:Array[WorldNode] = []
	
	func _init() -> void:
		stage = Stage.new()
		stage.generate()

func generate(depth):
	max_depth = depth
	nodes = {0: [WorldNode.new()]}
	populate_node(nodes[0][0],0)

func populate_node(current_node,current_depth):
	if current_depth == max_depth:
		return
		
	var next_depth = current_depth + 1
	randomize()
	var num_branches = randi_range(1,2)
	# First, check if there are any nodes already on the next level that we can connect to
	if nodes.has(next_depth):
		if randi_range(0,1) == 0:
			current_node.branches.append(nodes[next_depth].back())
			num_branches -= 1
	else:
		nodes[next_depth] = []
	
	# Then make new nodes and add them to the next level
	for branch in num_branches:
		var new_node = WorldNode.new()
		current_node.branches.append(new_node)
		nodes[next_depth].append(new_node)
	
	for node in current_node.branches:
		populate_node(node, next_depth)

func generate_map():
	var map = load("res://World/Map/Map.tscn").instantiate()
	map.generate(self)
	return map
