extends TileMapLayer

# 1. Define geography
# 2. Establish founding reason
# 3. Make main street from founding reason to *some point*
# 4. 

enum ATLANTES{WATER=40,ROAD=19,BUILDING=54,TRACKS=31}
const HEIGHT = 20
const WIDTH = 20
var altitude_grid
var average_altitude
var astar_grid:AStarGrid2D
var center:Vector2i
var num_landmarks = 3
var landmarks = []
var main_street
var roads = {}
var plots = {}
var train_station
var tracks = {}

func _ready():
	terrain_pass()
	choose_center()
	make_main_street()
	other_landmarks()
	place_plots()
	make_train_station()
	
	generate_terrain_mesh()
	place_building_meshes()
	place_tracks()
	#todo: make town first, then make path for train to follow, spawn players on train, have train stop at station

func terrain_pass():
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_VALUE
	noise.frequency = 0.1
	
	var lowest = 10000
	var highest = -10000
	for y in HEIGHT:
		for x in WIDTH:
			var where = Vector2(x,y)
			var val = noise.get_noise_2dv(where)
			if val < lowest:
				lowest = val
			if val > highest:
				highest = val
	#print("lowest: ", lowest)
	#print("highest: ", highest)
	
	average_altitude = (highest + lowest) / 2
	
	var shore_tiles = []
	var water_level = 1

	var num_steps = 10
	var step = (highest - lowest) / num_steps
	
	astar_grid = AStarGrid2D.new()
	astar_grid.region = Rect2i(0, 0, WIDTH, HEIGHT)
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.update()

	altitude_grid = make_2d_array(WIDTH,HEIGHT)
	for y in HEIGHT:
		for x in WIDTH:
			var where = Vector2(x,y)
			var val = noise.get_noise_2dv(where)
			var color = 0
			for i in num_steps:
				if not (val >= lowest + i * step && val < lowest + (i + 1) * step):
					continue
				altitude_grid[x][y] = i
				set_cell(where,0,Vector2i(i,0))
				if i <= water_level:
					set_cell(where,0,Vector2i(ATLANTES.WATER,0))
					astar_grid.set_point_weight_scale(where,1)
				if i == water_level + 1:
					# set_cell(where,0,Vector2i(14,0))
					shore_tiles.append(where)

func choose_center():
	# The center landmark that the town was built around,
	# not literally the center of the level
	center = Vector2i(WIDTH/2, 5)
	landmarks.append(center)
	sprite(center)

func make_main_street():
	var pos = center + Vector2i(randi_range(-5,5), 10)
	sprite(pos)
	main_street = astar_grid.get_id_path(center, pos, true)
	for tile in main_street:
		s(tile,ATLANTES.ROAD)
		roads[tile] = null

func other_landmarks():
	var step:int = (main_street.size() / num_landmarks) - 1
	var main_street_pos = step
	var direction = -1
	for i in num_landmarks:
		var intersection = main_street[main_street_pos]
		main_street_pos += step
		
		var x = randi_range(3,5) * direction
		direction *= -1
		
		var landmark_pos = (intersection + Vector2i(x,0))
		landmarks.append(landmark_pos)
		sprite(landmark_pos)
		var road = astar_grid.get_id_path(intersection, landmark_pos, true)
		for tile in road:
			s(tile,ATLANTES.ROAD)
			roads[tile] = null

func place_plots():
	for tile in roads:
		for neighbor in get_surrounding_cells(tile):
			var atlas = get_cell_atlas_coords(neighbor).x
			if atlas == ATLANTES.ROAD or atlas == ATLANTES.WATER or atlas == ATLANTES.BUILDING:
				continue
			s(neighbor,ATLANTES.BUILDING)
			plots[tile] = null

func make_train_station():
	train_station = landmarks.pick_random()
	var x = train_station.x
	var first_half = astar_grid.get_id_path(Vector2i(x,0),train_station)
	var second_half = astar_grid.get_id_path(train_station,Vector2i(x,HEIGHT - 1))
	for tile in first_half:
		s(tile,ATLANTES.TRACKS)
	for tile in second_half:
		s(tile,ATLANTES.TRACKS)

func generate_terrain_mesh() -> ArrayMesh:
	var generator = GroundMeshGenerator.new()
	return generator.generate_ground_mesh(altitude_grid,1.0,0.125)

func place_tracks():
	var track_tiles = get_used_cells_by_id(-1, Vector2i(ATLANTES.TRACKS, 0))
	var track_scene:PackedScene = load("res://train glbs/railroad-straight.glb")
	for tile in track_tiles:
		var mesh = track_scene.instantiate()
		mesh.position = tile_to_mesh(tile,altitude_grid[tile.x][tile.y])
		add_sibling.call_deferred(mesh)

func place_building_meshes():
	var building_tiles = get_used_cells_by_id(-1, Vector2i(ATLANTES.BUILDING, 0))
	var building_scene:PackedScene = load("res://suburb glbs/house.tscn")
	for tile in building_tiles:
		var mesh = building_scene.instantiate()
		mesh.position = tile_to_mesh(tile, average_altitude - (altitude_grid[tile.y][tile.x] * 0.125))
		add_sibling.call_deferred(mesh)

func tile_to_mesh(tile:Vector2i,height = 0) -> Vector3i:
	return Vector3i(tile.x * 10, height * 10, tile.y * 10)

func make_2d_array(w,h) -> Array:
	var array = []
	for i in w:
		array.append([])
		for j in h:
			array[i].append(0)
	return array

func sprite(tile):
	var sprite = Sprite2D.new()
	sprite.texture = load("res://icon.svg")
	sprite.scale = Vector2(0.125,0.125)
	add_child(sprite)
	sprite.position = map_to_local(tile)

func s(where,what):
	astar_grid.set_point_weight_scale(where,1)
	altitude_grid[where.x][where.y] = average_altitude
	set_cell(where,0,Vector2i(what,0))
