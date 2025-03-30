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
	for row in height:
		for col in width:
			var tile = Vector2i(row,col)
			var atlas = noise.get_noise_2dv(tile)
			atlas = abs(atlas)
			atlas = round(atlas * 20)
			print(atlas)
			if atlas <= WATER_LEVEL:
				atlas = WATER
			s(tile,atlas)

func s(where:Vector2i,atlas:int):
	set_cell(where,0,Vector2i(atlas,0))

func g(where):
	get_cell_atlas_coords(where)

func mesh():
	var mesh_instance = MeshInstance3D.new()
	var used_cells = get_used_cells()
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.6, 0.3)
	material.roughness = 0.7  # Slightly rough surface
	st.set_material(material)
	
	var vertex_count = 0
	
	# For each tile, create a square (two triangles)
	for cell_pos in used_cells:
		var atlas_coords = g(cell_pos)
		var depth = float(atlas_coords.x)  # Depth from atlas x value
		
		# Create a square for this tile
		var x = cell_pos.x
		var y = cell_pos.y
		
		# Vertices for this square
		var v1 = Vector3(x, -depth, y)
		var v2 = Vector3(x + 1, -depth, y)
		var v3 = Vector3(x, -depth, y + 1)
		var v4 = Vector3(x + 1, -depth, y + 1)
		
		# First triangle
		st.add_vertex(v1)
		st.add_vertex(v2)
		st.add_vertex(v3)
		
		# Second triangle
		st.add_vertex(v2)
		st.add_vertex(v4)
		st.add_vertex(v3)
		
		vertex_count += 6
	
	# Generate normals and assign mesh
	st.generate_normals()
	mesh_instance.mesh = st.commit()
	add_child(mesh_instance)
	
	print("Generated topography mesh with ", vertex_count, " vertices")
