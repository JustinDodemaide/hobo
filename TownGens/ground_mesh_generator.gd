class_name GroundMeshGenerator

func generate_ground_mesh(altitudes:Array, tile_size: float = 1.0, height_scale: float = 1.0) -> ArrayMesh:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var width = altitudes.size()
	var depth = altitudes[0].size()
	
	# Generate vertices and UVs
	for z in depth:
		for x in width:
			var vertex = Vector3(
				x * tile_size,
				altitudes[x][z] * height_scale,
				z * tile_size
			)
			
			# Calculate UVs (useful for texturing)
			var uv = Vector2(
				float(x) / (width - 1),
				float(z) / (depth - 1)
			)
			
			# Set normal (will be recalculated later)
			surface_tool.set_normal(Vector3.UP)
			surface_tool.set_uv(uv)
			surface_tool.add_vertex(vertex)
	
	# Generate triangles
	for z in range(depth - 1):
		for x in range(width - 1):
			var i = z * width + x
			
			# First triangle
			surface_tool.add_index(i)
			surface_tool.add_index(i + 1)
			surface_tool.add_index(i + width)
			
			# Second triangle
			surface_tool.add_index(i + 1)
			surface_tool.add_index(i + width + 1)
			surface_tool.add_index(i + width)
	
	# Recalculate normals for proper lighting
	surface_tool.generate_normals()
	
	# Optional: Generate tangents for normal mapping
	surface_tool.generate_tangents()
	
	return surface_tool.commit()

func update_mesh_heights(mesh: ArrayMesh, heightmap: Array, height_scale: float = 1.0) -> void:
	var arrays = mesh.surface_get_arrays(0)
	var vertices = arrays[Mesh.ARRAY_VERTEX]
	var width = heightmap.size()
	
	# Update Y coordinates based on heightmap
	for i in range(vertices.size()):
		var x = floor(i % width)
		var z = floor(i / width)
		vertices[i].y = heightmap[x][z] * height_scale
	
	# Create new mesh surface with updated vertices
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Rebuild mesh with new heights
	for i in range(vertices.size()):
		st.set_normal(arrays[Mesh.ARRAY_NORMAL][i])
		st.set_uv(arrays[Mesh.ARRAY_TEX_UV][i])
		st.add_vertex(vertices[i])
	
	# Add indices
	var indices = arrays[Mesh.ARRAY_INDEX]
	for i in range(0, indices.size(), 3):
		st.add_index(indices[i])
		st.add_index(indices[i + 1])
		st.add_index(indices[i + 2])
	
	# Recalculate normals
	st.generate_normals()
	st.generate_tangents()
	
	# Replace mesh surface
	mesh.surface_remove(0)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, st.commit().surface_get_arrays(0))

# Helper function for mesh optimization
func optimize_mesh(mesh: ArrayMesh, skip_rate: int = 2) -> ArrayMesh:
	var arrays = mesh.surface_get_arrays(0)
	var vertices = arrays[Mesh.ARRAY_VERTEX]
	var normals = arrays[Mesh.ARRAY_NORMAL]
	var uvs = arrays[Mesh.ARRAY_TEX_UV]
	var indices = arrays[Mesh.ARRAY_INDEX]
	
	var new_vertices = PackedVector3Array()
	var new_normals = PackedVector3Array()
	var new_uvs = PackedVector2Array()
	var new_indices = PackedInt32Array()
	
	# Create vertex mapping for optimization
	var vertex_map = {}
	var next_index = 0
	
	# Skip vertices based on skip_rate while maintaining topology
	for i in range(0, indices.size(), 3):
		var should_skip = (i / 3) % skip_rate != 0
		if not should_skip:
			for j in range(3):
				var idx = indices[i + j]
				var vertex = vertices[idx]
				var key = "%s_%s_%s" % [vertex.x, vertex.y, vertex.z]
				
				if not vertex_map.has(key):
					vertex_map[key] = next_index
					new_vertices.push_back(vertices[idx])
					new_normals.push_back(normals[idx])
					new_uvs.push_back(uvs[idx])
					next_index += 1
				
				new_indices.push_back(vertex_map[key])
	
	# Create new optimized mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(new_vertices.size()):
		st.set_normal(new_normals[i])
		st.set_uv(new_uvs[i])
		st.add_vertex(new_vertices[i])
	
	for i in range(new_indices.size()):
		st.add_index(new_indices[i])
	
	st.generate_normals()
	st.generate_tangents()
	
	return st.commit()
