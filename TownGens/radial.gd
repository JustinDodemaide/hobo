extends TileMapLayer

# **Radial Towns**: These develop around a central point, such as a market or church

enum ATLANTES{WATER=40,ROAD=19,BUILDING=54}

var width = 20
var height = 20
var astar_grid:AStarGrid2D
var center
var num_rings = 3
var distance_between_rings = 3
var landmarks_per_ring = 2
var landmark_rings:Array[Array] = []
var landmarks = []
var road_tiles = {}

func _ready() -> void:
	terrain_pass()
	choose_center()
	other_landmarks()
	paths()
	buildings()

func terrain_pass():
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_VALUE
	noise.frequency = 0.1
	
	var lowest = 10000
	var highest = -10000
	for y in height:
		for x in width:
			var where = Vector2(x,y)
			var val = noise.get_noise_2dv(where)
			if val < lowest:
				lowest = val
			if val > highest:
				highest = val
	#print("lowest: ", lowest)
	#print("highest: ", highest)
	
	var shore_tiles = []
	var water_level = 1

	var num_steps = 10
	var step = (highest - lowest) / num_steps
	
	astar_grid = AStarGrid2D.new()
	astar_grid.region = Rect2i(0, 0, width, height)
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.update()

	for y in height:
		for x in width:
			var where = Vector2(x,y)
			var val = noise.get_noise_2dv(where)
			var color = 0
			for i in num_steps:
				if (val >= lowest + i * step && val < lowest + (i + 1) * step):
					s(where,i)
					if i <= water_level:
						s(where,ATLANTES.WATER)
						astar_grid.set_point_weight_scale(where,1)
					if i == water_level + 1:
						# set_cell(where,0,Vector2i(14,0))
						shore_tiles.append(where)

func choose_center():
	# The center landmark that the town was built around,
	# not literally the center of the level
	center = Vector2i(width/2,height/2)
	landmarks.append(center)
	sprite(center)
	
	var radius = 4
	for i in num_rings:
		var points = []
		var x = 0
		var y = radius
		var d = 3 - 2 * radius
		
		while x <= y:
			points.append(center + Vector2i(x, y))
			points.append(center + Vector2i(-x, y))
			points.append(center + Vector2i(x, -y))
			points.append(center + Vector2i(-x, -y))
			points.append(center + Vector2i(y, x))
			points.append(center + Vector2i(-y, x))
			points.append(center + Vector2i(y, -x))
			points.append(center + Vector2i(-y, -x))
			if d <= 0:
				d += 4 * x + 6
			else:
				d += 4 * (x - y) + 10
				y -= 1
			x += 1
		radius += distance_between_rings
		
		#for point in points:
		#	set_cell(point,0,Vector2i(15,0))
		if points.size() == 0:
			pass
		landmark_rings.append(points)

# Maybe make rings around the center and put the landmarks somewhere on each ring
func other_landmarks():
	for ring in num_rings:
		for i in landmarks_per_ring:
			var potential_spaces := landmark_rings[ring]
			potential_spaces.shuffle()
			var potential_space = potential_spaces.pop_back()
			# Make sure the space is actually traversable
			while not_traversable(potential_space):
				potential_space = potential_spaces.pop_back()
			sprite(potential_space)
			landmarks.append(potential_space)

func not_traversable(where) -> bool:
	var atlas = get_cell_atlas_coords(where)
	if atlas.x == 40:
		return true
	return false
	
	var weight = astar_grid.get_point_weight_scale(where)
	return astar_grid.get_point_weight_scale(where) != 0

func paths():
	# Connect each landmark to a few other ones
	var num_connections = 2
	for from in landmarks:
		var connections = []
		for i in num_connections:
			connections.append(landmarks.pick_random())
		for to in connections:
			var path = astar_grid.get_id_path(from, to, true)
			for path_tile in path:
				road_tiles[path_tile] = null # use a dictionary so each tile is unique
				s(path_tile,ATLANTES.ROAD)

func buildings():
	for tile in road_tiles:
		for neighbor in get_surrounding_cells(tile):
			var atlas = get_cell_atlas_coords(neighbor).x
			if atlas == ATLANTES.ROAD or atlas == ATLANTES.WATER or atlas == ATLANTES.BUILDING:
				continue
			s(neighbor,ATLANTES.BUILDING)

func sprite(tile):
	var sprite = Sprite2D.new()
	sprite.texture = load("res://icon.svg")
	sprite.scale = Vector2(0.125,0.125)
	add_child(sprite)
	sprite.position = map_to_local(tile)

func s(where,what):
	set_cell(where,0,Vector2i(what,0))
