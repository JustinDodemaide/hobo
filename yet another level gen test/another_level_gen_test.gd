extends Node3D

# Important note: left/right are x and z, up/down is y

# Get geography
# Make town layout
# Make station, apart from town

var level
const WIDTH:int = 20
const HEIGHT:int = 20
const TILE_SIZE:float = 4.5
const HEIGHT_SCALE:float = 1.0 * TILE_SIZE

# At lower height scales, the noise values can be negative, which breaks
# the astar grid, so just adding 1 fixes that
const ALTITUDE_BUFFER:int = 1
var terrain_specs:Dictionary = {
	"altitude_map": null,
	"highest_altitude": null,
	"median_altitude":null,
	"lowest_altitude": null,
}

var astar_grid

var tilemap = TileMapLayer.new()
enum {STREET,BUILDING,TRACK}

var station:Vector2

func _init(_level) -> void:
	_level = level

func generate():
	init_terrain_specs()
	generate_ground_mesh()
	generate_grid_layout()
	place_building_meshes()
	place_train_meshes()

func init_terrain_specs() -> void:
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.1
	terrain_specs.altitude_map = noise
	
	var lowest = 10000
	var highest = -10000
	for y in HEIGHT:
		for x in WIDTH:
			var where = Vector2(x,y)
			var val = get_height_at(where)
			if val < lowest:
				lowest = val
			if val > highest:
				highest = val
	
	lowest += ALTITUDE_BUFFER
	highest += ALTITUDE_BUFFER
	
	terrain_specs.lowest_altitude = lowest + 1
	terrain_specs.median_altitude = (lowest + highest) / 2
	terrain_specs.highest_altitude = highest

func generate_ground_mesh():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = Rect2i(0, 0, WIDTH, HEIGHT)
	astar_grid.cell_size = Vector2(TILE_SIZE, TILE_SIZE)
	astar_grid.update()

	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Generate vertices and UVs
	for y in HEIGHT:
		for x in WIDTH:
			var cell = Vector2(x,y)
			var z = get_height_at(cell)
			astar_grid.set_point_weight_scale(cell, z)
			var vertex = Vector3(
				x * TILE_SIZE,
				z,
				y * TILE_SIZE
			)
			
			# Calculate UVs (useful for texturing)
			var uv = Vector2(
				float(x) / (WIDTH - 1),
				float(z) / (HEIGHT - 1)
			)
			
			# Set normal (will be recalculated later)
			surface_tool.set_normal(Vector3.UP)
			surface_tool.set_uv(uv)
			surface_tool.add_vertex(vertex)
	
	# Generate triangles
	for y in HEIGHT - 1:
		for x in WIDTH - 1:
			var i = y * WIDTH + x
			
			# First triangle
			surface_tool.add_index(i)
			surface_tool.add_index(i + 1)
			surface_tool.add_index(i + WIDTH)
			
			# Second triangle
			surface_tool.add_index(i + 1)
			surface_tool.add_index(i + WIDTH + 1)
			surface_tool.add_index(i + WIDTH)
	
	# Recalculate normals for proper lighting
	surface_tool.generate_normals()
	
	# Optional: Generate tangents for normal mapping
	surface_tool.generate_tangents()
	
	var mesh = MeshInstance3D.new()
	mesh.mesh = surface_tool.commit()
	mesh.create_trimesh_collision()
	mesh.get_children()[0].collision_layer = 0b11
	mesh.get_children()[0].collision_mask = 0b11
	level.add_child(mesh)
	
	var material:Material = StandardMaterial3D.new()
	material.albedo_color = Color(0.76,0.69,0.50)
	mesh.material_override = material

#region Town Layouts Procedures
const TOWN_SIZE := 10
const MAX_BLOCK_WIDTH := 6
const MAX_BLOCK_HEIGHT := 2
func generate_grid_layout():
	tilemap.tile_set = load("res://TownGens/test_level_gens.tres")
	
	# Make the layout all buildings first, then do the streets
	for x in TOWN_SIZE:
		for y in TOWN_SIZE:
			tm_set(Vector2i(x,y), BUILDING)
	
	# Streets
	for y in range(0,TOWN_SIZE,2):
		for x in TOWN_SIZE:
			# Fill in the row
			tm_set(Vector2i(x,y),STREET)
		
		# Place side streets connecting rows
		var intersections = []
		var x = 0
		while x < TOWN_SIZE:
			x += randi_range(2,MAX_BLOCK_WIDTH)
			if x > TOWN_SIZE:
				break
			intersections.append(x)
		for i in intersections:
			var side_street = Vector2i(i,y)
			for var_names_are_hard in MAX_BLOCK_HEIGHT:
				side_street.y += var_names_are_hard
				tm_set(side_street, STREET)
	
	var displacement = Vector2(round((WIDTH - TOWN_SIZE) / 2),
								round((HEIGHT - TOWN_SIZE) / 2))
	station = Vector2(TOWN_SIZE, TOWN_SIZE/2) + displacement
	#level.get_node("Player").get_node("Camera3D").add_child(tilemap)

const NUM_LANDMARKS := 3
func generate_linear_layout():
	var center = Vector2i(WIDTH/2, HEIGHT/4)
	var street = astar_grid.get_id_path(center, Vector2i(center.x, HEIGHT - 2))

	var step:int = (street.size() / NUM_LANDMARKS) - 1
	var street_pos = step
	var direction = -1
	var station_landmark_num = randi_range(0,NUM_LANDMARKS - 1)
	var station
	for i in NUM_LANDMARKS:
		var intersection = street[street_pos]
		street_pos += step
		
		var x = randi_range(3,5) * direction
		direction *= -1
		
		var landmark_pos = (intersection + Vector2i(x,0))
		var side_street = astar_grid.get_id_path(intersection, landmark_pos)
		street.append_array(side_street)
		
		if i == station_landmark_num: # not really elegant but w/e
			station = side_street.back()
	
	for cell in street:
		tm_set(cell, STREET)
	
	var start_x = station.x + randi_range(-3,3)
	var end_x = station.x + randi_range(-3,3)
	var first_half = astar_grid.get_id_path(Vector2i(start_x, 0), station)
	var second_half = astar_grid.get_id_path(station, Vector2i(end_x, HEIGHT - 1))
	first_half.append_array(second_half)
		
	var curve = Curve3D.new()
	for cell in first_half:
		var z = get_height_at(cell)
		curve.add_point(Vector3(cell.x,cell.y,z))
		tm_set(cell,TRACK)
	var path = Path3D.new()
	path.name = "Tracks"
	path.curve = curve
	level.add_child(path)
	
	tilemap.tile_set = load("res://TownGens/test_level_gens.tres")
	for cell in street:
		cell *= TILE_SIZE
		var sprite = Sprite3D.new()
		sprite.texture = load("res://icon.svg")
		# level.add_child(sprite)
		sprite.position = Vector3(cell.x,1,cell.y)
		
		for neighbor in tilemap.get_surrounding_cells(cell):
			if impassable(neighbor):
				continue
			tm_set(neighbor,BUILDING)
			neighbor *= TILE_SIZE
			var building_mesh = load("res://suburb glbs/house.tscn").instantiate()
			level.add_child(building_mesh)
			building_mesh.position = Vector3(neighbor.x,1,neighbor.y) * TILE_SIZE
	
	minimap_sprite.texture = load("res://icon.svg")
	update_minimap()
#endregion

func place_building_meshes():
	var displacement = Vector2i(round((WIDTH - TOWN_SIZE) / 2),
								round((HEIGHT - TOWN_SIZE) / 2))
	for cell in tilemap.get_used_cells_by_id(-1, Vector2i(BUILDING, 0)):
		cell += displacement
		var height = get_height_at(cell)
		var building_mesh = load("res://suburb glbs/house.tscn").instantiate()
		level.add_child(building_mesh)
		building_mesh.position = Vector3(cell.x * TILE_SIZE, height, cell.y * TILE_SIZE)

func place_train_meshes():
	# Get the highest altitude on the train's path
	var highest = -10000
	for y in HEIGHT:
		var tile = Vector2(station.x, y)
		var height = get_height_at(tile)
		if height > highest:
			highest = height
	
	var z = highest
	var curve = Curve3D.new()
	for y in HEIGHT:
		var cell = Vector2(station.x, y) * TILE_SIZE
		curve.add_point(Vector3(cell.x, z, cell.y))
		tm_set(cell,TRACK)
		
	level.path.curve = curve

#region Helper Functions
func tm_set(where,atlas:int):
	tilemap.set_cell(where,0,Vector2i(atlas,0))

func impassable(where) -> bool:
	var atlas = tilemap.get_cell_atlas_coords(where).x
	if atlas == STREET or atlas == BUILDING or atlas == TRACK:
		return true
	return false

var minimap_sprite = Sprite2D.new()
func update_minimap() -> void:
	var player_pos = level.get_node("Player").position
	minimap_sprite.position = Vector2(player_pos.x, player_pos.z) * TILE_SIZE * 8
	minimap_sprite.scale = Vector2(player_pos.y,player_pos.y) / 10
	var timer = level.get_tree().create_timer(0.1)
	timer.timeout.connect(update_minimap)

func get_height_at(where:Vector2) -> float:
	return (terrain_specs.altitude_map.get_noise_2dv(where) + ALTITUDE_BUFFER) * HEIGHT_SCALE
#endregion
