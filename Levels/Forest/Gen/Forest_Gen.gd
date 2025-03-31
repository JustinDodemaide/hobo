extends TileMapLayer
var level
var height = 100
var width = 100
const WATER_LEVEL = 1
const WATER = 47

func _ready() -> void:
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
			s(tile,atlas)
	mesh()

func s(where:Vector2i,atlas:int):
	set_cell(where,0,Vector2i(atlas,0))

func g(where):
	return get_cell_atlas_coords(where).x

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
	
	# Define tile size
	var tile_size = 12.0  # 12 meters per tile
	var height_scale = tile_size / 2
	
	# Create mesh data
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Generate vertices grid
	for x in range(width + 1):
		for y in range(height + 1):
			var world_x = min_x + x
			var world_y = min_y + y
			var depth = g(Vector2i(world_x, world_y))
			
			# Add vertex - scale x and z by tile_size
			st.add_vertex(Vector3(x * tile_size, depth * height_scale, y * tile_size))
	
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
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.6, 0.3)
	material.roughness = 1
	material.cull_mode = BaseMaterial3D.CULL_DISABLED  # Show both sides
	st.set_material(material)
	
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
	water_plane.position.x = (width * tile_size) / 2
	water_plane.position.y = WATER_LEVEL * height_scale
	water_plane.position.z = (height * tile_size) / 2
	
	water_plane.scale.x = width * tile_size
	water_plane.scale.z = height * tile_size
	mesh_instance.add_child(water_plane)
	
	level.add_child.call_deferred(mesh_instance)

func get_average_neighbor_depth(pos: Vector2i) -> float:
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
			var tile_data = g(neighbor)
			total_depth += float(tile_data.x)
			count += 1

	if count > 0:
		return total_depth / count
	else:
		return 0.0  # Default depth if no neighbors found
