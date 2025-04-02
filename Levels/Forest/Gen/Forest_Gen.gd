extends TileMapLayer
var level
var height = 100
var width = 100
const WATER_LEVEL = 1
var tile_scale = 24
var height_scale = 6#tile_scale / 2

# for the foliage - convert the potential position to a map coord to see if its occupied
# use seperate meshes for the roads, water, grass
# have one key business for the level
# use astar to make roads between buildings
# use another tile layer for buildings, roads and water, use the original tile layer for altitudes
# the swamp is really just the forest with a lower height scale
# we're doing this biome by biome - right now, we're exclusively focusing on the forest
# (we can make multiple level "premises" or layouts or pois from just one biome - we dont need a
# different biome for each idea (swamp for fishing, mountains for mining, desert for whatever)
# that way we can save a lot of time on things like assets and level gen 
# to add an element to the route selection, maybe their can be day phases between checkpoints. Like if
# there's 3 stops between each checkpoint, maybe have it go morning-afternoon-night so the players also
# have to factor in like "this route looks good but we'll be in the logging camp at night which is bad
# (assuming time of day effects things)
# or it could be arbitrary. who's to say one between-stops cant take 12 hours while another is only 3
# in that case itll be just like the random whether. Maybe we should have an interaction matrix
# for biomes/weather/day. How would forest/clear/night look different from forest/stormy/night?
# do these conditions compound or do they combine? do high winds interact with night differently than noon?
# obviously the wind wouldnt change but I mean the presence of npcs or items
# these interaction matrices make a lot of depth out of only a few features!!
# only problem is, the complexity compounds. which isnt a big problem for implementation i dont think, but could
# be a problem for players trying to predict how things will behave. depth is good but too many variables
# just becomes a mental chess game (and not in a fun way), so you gotta strike a balance. different sigils are good, but multi strike + movement + mighty leap makes things hard to keep track of!

func _ready() -> void:
	terrain()
	buildings()

func terrain():
	level = get_parent()
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.005
	for row in height:
		for col in width:
			var tile = Vector2i(row,col)
			var atlas = noise.get_noise_2dv(tile)
			atlas = abs(atlas)
			atlas = round(atlas * 20)
			# print(atlas)
			#if atlas <= WATER_LEVEL:
			#    atlas = WATER
			_s(self,tile,atlas)
	mesh()

func mesh():
	var used_cells = get_used_cells()  # 0 is the layer index
	if used_cells.is_empty():
		return
	
	# Find bounds of the tilemap
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	
	for cell in used_cells:
		min_x = min(min_x, cell.x)
		max_x = max(max_x, cell.x)
		min_y = min(min_y, cell.y)
		max_y = max(max_y, cell.y)
	
	var width = max_x - min_x + 1
	var height = max_y - min_y + 1
	
	# Create mesh data
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Generate vertices grid
	for x in range(width + 1):
		for y in range(height + 1):
			var world_x = min_x + x
			var world_y = min_y + y
			var depth = _g(self, Vector2i(world_x, world_y))
			
			st.set_uv(Vector2(x,y) * tile_scale)
			# Add vertex - scale x and z by tile_size
			st.add_vertex(Vector3(x * tile_scale, depth * height_scale, y * tile_scale))
	
	# Create triangles by connecting vertices
	for x in range(width):
		for y in range(height):
			var i00 = y * (width + 1) + x
			var i10 = y * (width + 1) + x + 1
			var i01 = (y + 1) * (width + 1) + x
			var i11 = (y + 1) * (width + 1) + x + 1
			
			# First triangle
			st.add_index(i00)
			st.add_index(i10)
			st.add_index(i01)
			
			# Second triangle
			st.add_index(i10)
			st.add_index(i11)
			st.add_index(i01)
	
	# Material
	st.set_material(load("res://Levels/Forest/Gen/grass material.tres"))
	
	# Generate normals and assign mesh
	var mesh_instance = MeshInstance3D.new()
	st.generate_normals()
	mesh_instance.mesh = st.commit()
	
	# StaticBody
	var collision_shape = CollisionShape3D.new()
	var concave_shape = ConcavePolygonShape3D.new()
	var mesh_data = mesh_instance.mesh.get_faces()
	concave_shape.set_faces(mesh_data)
	collision_shape.shape = concave_shape
	
	var static_body = StaticBody3D.new()
	static_body.add_child(collision_shape)
	mesh_instance.add_child(static_body)
	
	# Water
	var water_plane = load("res://Shaders/WaterPlane.tscn").instantiate()
	water_plane.position.x = (width * tile_scale) / 2
	water_plane.position.y = (WATER_LEVEL) * height_scale
	water_plane.position.z = (height * tile_scale) / 2
	
	water_plane.scale.x = width * tile_scale
	water_plane.scale.z = height * tile_scale
	mesh_instance.add_child(water_plane)
	
	level.add_child.call_deferred(mesh_instance)

func _get_average_neighbor_depth(pos: Vector2i) -> float:
	var neighbors = [
		Vector2i(pos.x + 1, pos.y),
		Vector2i(pos.x - 1, pos.y),
		Vector2i(pos.x, pos.y + 1),
		Vector2i(pos.x, pos.y - 1)
	]

	var total_depth = 0.0
	var count = 0

	for neighbor in neighbors:
		var cell_data = get_cell_source_id(neighbor)
		if cell_data != -1:
			var tile_data = _g(self, neighbor)
			total_depth += float(tile_data)
			count += 1

	if count > 0:
		return total_depth / count
	else:
		return 0.0  # Default depth if no neighbors found

func buildings():
	const ROAD = 2
	const BUILDING = 3
	const TRACK = 7
	
	# decide on a key feature - mine, fishing, logging
	# just doing logging for now
	#	just make a rectangle in the middle for the camp clearing
	# scatter other landmarks around the forest?
	logging_camp()

func logging_camp():
	const CLEARING = 21
	var clearing_size_x = 16
	var clearing_size_y = 16
	
	# we need a place thats near the water but we cant have the clearing be in
	# the water
	var valid_positions = get_used_cells_by_id(0,Vector2i(WATER_LEVEL + 1,0)).pick_random()
	var position_scores = {}
	var center = Vector2(width,height) / 2

	var shore_tiles = get_used_cells_by_id(0,Vector2i(WATER_LEVEL + 1,0))
	var closest_tile_to_center = shore_tiles.front()
	var closest_distance_to_center = INF
	for tile in shore_tiles:
		var distance_to_center = tile.distance_to(center)
		if distance_to_center < closest_distance_to_center:
			closest_distance_to_center = distance_to_center
			closest_tile_to_center = tile
			
	var clearing_top_left = closest_tile_to_center - Vector2i(clearing_size_x,clearing_size_y) / 2
	for x in clearing_size_x:
		for y in clearing_size_y:
			var tile = Vector2i(x,y) + clearing_top_left
			if is_water(tile):
				continue
			_s(self,tile, CLEARING)
			
			var mesh = load("res://Levels/Forest/Gen/mesh_instance_3d.tscn").instantiate()
			var cell = map_to_local(tile) * tile_scale
			mesh.global_position = Vector3(cell.x, _g(self, tile),cell.y)
			level.add_child.call_deferred(mesh)
			
	var clearing_tiles = $Buildings.get_used_cells_by_id(0,Vector2(CLEARING,0))
	

func _s(which:TileMapLayer,where:Vector2i,atlas:int):
	which.set_cell(where,0,Vector2i(atlas,0))

func _g(which,where):
	return which.get_cell_atlas_coords(where).x

func is_water(tile:Vector2i) -> bool:
	if get_cell_atlas_coords(tile).x <= WATER_LEVEL:
		return true
	return false
