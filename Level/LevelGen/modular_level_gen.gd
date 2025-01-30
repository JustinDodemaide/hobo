extends Node
class_name LevelGen

enum{GROUND,WATER}
@onready var terrain:TileMapLayer = $Terrain
enum{STREET,PLOT,TRACKS,STATION}
@onready var buildings:TileMapLayer = $Buildings
var height:Array = []

var level:Level
const LENGTH:int = 35
const WIDTH:int = 35

const TILE_TO_METER_RATIO:int = 10

const plots = [
"res://Plots/grid town/store_plot.tscn",
"res://Plots/grid town/misc_building2.tscn",
"res://Plots/grid town/misc_building4.tscn",
]

func _ready() -> void:
	pass
	#generate()

func generate():
	for x in LENGTH:
		height.append([])
		for y in WIDTH:
			height.append(0.0)
	# Make 2D first
	# Make terrain noise
	# Translate 2D to 3D
	var terrain = TerrainGen.new()
	terrain.set_terrain(self, terrain.GRASSLAND)
	var building_layout = BuildingLayouts.new()
	building_layout.set_buildings(self, building_layout.GRID)
	path()
	terrain_mesh()
	structures()

func path() -> void:
	const CURVE_DEPTH:int = 30
	var station = Vector2i(WIDTH/2, LENGTH/3)
	var curve = Curve3D.new()
	var curve_vector_y = TILE_TO_METER_RATIO / 2
	#var last_point = null
	for x in range(-WIDTH,WIDTH):
		var y = (x*x) / CURVE_DEPTH
		var tile = Vector2i(x,y) + station
		tset(buildings,tile,TRACKS)
		var cell = Vector3(tile.x * TILE_TO_METER_RATIO, 0, tile.y * TILE_TO_METER_RATIO)
		#Log.prn(cell)
		#if !last_point:
		#	curve.add_point(cell), Vector3(-curve_vector_y,0,0), Vector3(curve_vector_y,0,0))
		curve.add_point(cell)#, Vector3(-curve_vector_y,0,0), Vector3(curve_vector_y,0,0))
	tset(buildings,station,STATION)
	level.path.curve = curve

func terrain_mesh() -> void:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Generate vertices and UVs
	for y in LENGTH:
		for x in WIDTH:
			var cell = Vector2(x,y)
			var z = get_height(cell)
			var vertex = Vector3(
				x,
				z,
				y
			)
			vertex.x *= TILE_TO_METER_RATIO
			vertex.y *= TILE_TO_METER_RATIO
			vertex.z *= TILE_TO_METER_RATIO
			
			# Calculate UVs
			var uv = Vector2(
				float(x) / (WIDTH - 1),
				float(z) / (LENGTH - 1)
			)
			
			# Set normal (will be recalculated later)
			surface_tool.set_normal(Vector3.UP)
			surface_tool.set_uv(uv)
			surface_tool.add_vertex(vertex)
	
	# Generate triangles
	for y in LENGTH - 1:
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
	#material.albedo_color = Color(0.76,0.69,0.50)
	material.albedo_color = Color(0.384,0.333,0.396)
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

func structures():
	#var offsets = [-0.03, -0.02, -0.01, 0.0, 0.01, 0.02, 0.03]
	var offset = 0.0001
	# Need to offset the hieghts of adjacent plots to prevent foundation z-fighting
	for tile in buildings.get_used_cells_by_id(0, Vector2i(PLOT, 0)):
		var cell = tile * TILE_TO_METER_RATIO
		var plot = load(plots.pick_random()).instantiate()
		var height = get_height(tile) + offset# + offsets.pick_random()
		plot.position = Vector3(cell.x, height, cell.y)
		level.add_child(plot)
		
		offset += 0.0001

func tset(which:TileMapLayer,where:Vector2i,what:int):
	which.set_cell(where, 0, Vector2i(what, 0))

func tget(which:TileMapLayer,where:Vector2i) -> int:
	return which.get_cell_atlas_coords(where).x

func get_height(where:Vector2i):
	return 0

func _process(delta: float) -> void:
	var player = level.get_node("Player")
	if not player:
		return
	var pos = player.global_position / TILE_TO_METER_RATIO
	var tile = Vector2(pos.x,pos.z) * 8
	$Sprite2D.position = tile
