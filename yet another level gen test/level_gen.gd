var level

enum {STREET,BUILDING,TRACK,GROUND=63}
const TOWN_WIDTH:int = 10
const TOWN_LENGTH:int = 10
const OUTSKIRT_SIZE:int = 2
const MAX_BLOCK_HEIGHT:int = 2
const MAX_BLOCK_WIDTH:int = 3
const ALLEY_SIZE:int = TILE_TO_METER_RATIO / 2
const LEVEL_WIDTH:int = OUTSKIRT_SIZE + TOWN_WIDTH + OUTSKIRT_SIZE
const LEVEL_LENGTH:int = OUTSKIRT_SIZE + TOWN_LENGTH + OUTSKIRT_SIZE

const TILE_TO_METER_RATIO:int = 12

var terrain_specs = {
	"altitude_map":null,
	
}

var tilemap
func generate():
	# make the terrain
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.1
	terrain_specs.altitude_map = noise
	
	var lowest = 10000
	var highest = -10000
	for y in LEVEL_LENGTH:
		for x in LEVEL_WIDTH:
			var where = Vector2(x,y)
			var val = get_unscaled_height_at(where)
			if val < lowest:
				lowest = val
			if val > highest:
				highest = val
	
	terrain_specs.lowest_altitude = lowest
	terrain_specs.median_altitude = (lowest + highest) / 2
	terrain_specs.highest_altitude = highest

	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Generate vertices and UVs
	for y in LEVEL_LENGTH:
		for x in LEVEL_WIDTH:
			var cell = Vector2(x,y)
			var z = get_unscaled_height_at(cell)
			var vertex = Vector3(
				x,
				z,
				y
			)
			vertex.x *= TILE_TO_METER_RATIO
			vertex.y *= TILE_TO_METER_RATIO / 2
			vertex.z *= TILE_TO_METER_RATIO
			
			# Calculate UVs
			var uv = Vector2(
				float(x) / (LEVEL_WIDTH - 1),
				float(z) / (LEVEL_LENGTH - 1)
			)
			
			# Set normal (will be recalculated later)
			surface_tool.set_normal(Vector3.UP)
			surface_tool.set_uv(uv)
			surface_tool.add_vertex(vertex)
	
	# Generate triangles
	for y in LEVEL_LENGTH - 1:
		for x in LEVEL_WIDTH - 1:
			var i = y * LEVEL_WIDTH + x
			
			# First triangle
			surface_tool.add_index(i)
			surface_tool.add_index(i + 1)
			surface_tool.add_index(i + LEVEL_WIDTH)
			
			# Second triangle
			surface_tool.add_index(i + 1)
			surface_tool.add_index(i + LEVEL_WIDTH + 1)
			surface_tool.add_index(i + LEVEL_WIDTH)
	
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
	
	var grass_system = GrassSystem.new()
	# Optional parameters after level_gen
	var grass_instance = grass_system.create_grass_system(self, 1, 0.3, 1.0)
	mesh.add_child(grass_instance)
	
	var nav_mesh = NavigationMesh.new()
	nav_mesh.cell_size = 0.5  # Size of each navigation cell
	nav_mesh.cell_height = 0.4  # Height of each cell
	nav_mesh.agent_height = 1.5  # Height of agents that will navigate
	nav_mesh.agent_radius = 0.4  # Radius of agents
	nav_mesh.agent_max_climb = 0.9  # Maximum height agents can climb
	nav_mesh.agent_max_slope = 45.0  # Maximum slope in degrees
	nav_mesh.create_from_mesh(mesh.mesh)
	var nav_region = NavigationRegion3D.new()
	nav_region.navigation_mesh = nav_mesh
	mesh.add_child(nav_region)	
	# make the towns layout
	tilemap = TileMapLayer.new()
	tilemap.tile_set = load("res://TownGens/test_level_gens.tres")
	for x in LEVEL_WIDTH:
		for y in LEVEL_LENGTH:
			var tile = Vector2i(x,y)
			tm_set(tile,GROUND)

	var displacement:Vector2i = Vector2i(OUTSKIRT_SIZE,OUTSKIRT_SIZE)
	for x in TOWN_WIDTH:
		for y in TOWN_LENGTH:
			tm_set(Vector2i(x,y) + displacement, BUILDING)

	for y in range(0,TOWN_LENGTH,2):
		for x in TOWN_WIDTH:
			# Fill in the row
			tm_set(Vector2i(x,y) + displacement, STREET)
		
		# Place side streets connecting rows
		var intersections = []
		var x = 0
		while x < TOWN_WIDTH:
			x += randi_range(2,MAX_BLOCK_WIDTH)
			if x > TOWN_WIDTH:
				break
			intersections.append(x)
		for i in intersections:
			var side_street = Vector2i(i,y)
			for var_names_are_hard in MAX_BLOCK_HEIGHT:
				side_street.y += var_names_are_hard
				tm_set(side_street + displacement, STREET)

	for tile_y in LEVEL_LENGTH:
		var level_y = tile_y * TILE_TO_METER_RATIO
		for tile_x in LEVEL_WIDTH:
			var level_x = tile_x * TILE_TO_METER_RATIO
			var tile = Vector2i(tile_x,tile_y)
			if tm_get(tile) == BUILDING:
				place_foundation(level_x, level_y)
			var next_tile = Vector2i(tile_x + 1, tile_y)

	# Get the highest altitude on the train's path
	var station_x = OUTSKIRT_SIZE
	highest = -10000
	for y in LEVEL_LENGTH:
		var tile = Vector2(station_x, y)
		var height = get_unscaled_height_at(tile)
		if height > highest:
			highest = height
	
	var z = highest
	var curve = Curve3D.new()
	for y in LEVEL_LENGTH:
		var cell = Vector2(station_x, y)
		curve.add_point(Vector3(cell.x, z, cell.y) * TILE_TO_METER_RATIO)
		tm_set(cell,TRACK)
		
	level.path.curve = curve

func tm_set(where,atlas:int):
	tilemap.set_cell(where,0,Vector2i(atlas,0))

func tm_get(where) -> int:
	return tilemap.get_cell_atlas_coords(where).x

func place_foundation(x, y):
	var foundation = load("res://Foundation/foundation.tscn").instantiate()
	foundation.init(terrain_specs.highest_altitude, terrain_specs.lowest_altitude)
	level.add_child(foundation)
	foundation.position = Vector3(x, get_unscaled_height_at(Vector2(x,y)), y)

func get_unscaled_height_at(where:Vector2) -> float:
	return (terrain_specs.altitude_map.get_noise_2dv(where))
