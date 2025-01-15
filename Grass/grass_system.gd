class_name GrassSystem

var grass_density: float = 1.0
var wind_strength: float = 0.2
var wind_speed: float = 1.0
var grass_height_range := Vector2(0.3, 0.5)

var grass_models: Array[Mesh] = [
		#load("res://Grass/Grass.obj"),
		#load("res://Grass/Grass_2.obj"),
		load("res://Grass/Grass_Short.obj"),
	]

func create_grass_system(level_gen, density: float = 1.0, w_strength: float = 0.2, w_speed: float = 1.0) -> MultiMeshInstance3D:
	grass_density = density
	wind_strength = w_strength
	wind_speed = w_speed
	
	#var blade_height = randf_range(grass_height_range.x, grass_height_range.y)
	#var blade = create_grass_blade(blade_height)
	var blade = get_random_grass()
	var num_blades = round(level_gen.LEVEL_WIDTH * level_gen.LEVEL_LENGTH * grass_density)
	
	var grass_mesh = MultiMesh.new()
	grass_mesh.transform_format = MultiMesh.TRANSFORM_3D
	grass_mesh.mesh = blade
	grass_mesh.instance_count = num_blades
	
	#var distribution_noise = FastNoiseLite.new()
	#distribution_noise.seed = randi()
	#distribution_noise.frequency = 0.1
	
	for i in num_blades:
		var transform = Transform3D()
		
		var pos = Vector2(randi_range(0, level_gen.LEVEL_WIDTH - 2), randi_range(0, level_gen.LEVEL_LENGTH - 2))
		var displacement = Vector2(randf_range(0, 1), randf_range(0, 1))
		
		# Use bilinear interpolation to get the height at the displaced pos
		# Get heights at the four corners of our grid cell
		var y00 = level_gen.get_unscaled_height_at(Vector2(pos.x, pos.y)) /2        # Bottom left
		var y10 = level_gen.get_unscaled_height_at(Vector2(pos.x + 1, pos.y))/2     # Bottom right
		var y01 = level_gen.get_unscaled_height_at(Vector2(pos.x, pos.y + 1)) /2    # Top left
		var y11 = level_gen.get_unscaled_height_at(Vector2(pos.x + 1, pos.y + 1))/2 # Top right

		var dx = displacement.x
		var dy = displacement.y
		# First interpolate in x direction along both rows
		var y0 = y00 * (1 - dx) + y10 * dx  # Bottom row
		var y1 = y01 * (1 - dx) + y11 * dx  # Top row

		# Then interpolate between those results in y direction
		var z = y0 * (1 - dy) + y1 * dy
		
		
		#var noise_val = distribution_noise.get_noise_2d(grid_x, grid_y)
		#if noise_val < -0.2: # Made this more permissive for better coverage
		#	continue
		
		# Set pos and rotation, scale kept messing up the elevation so forgoing that
		pos += displacement
		transform.origin = Vector3(pos.x, z, pos.y) * level_gen.TILE_TO_METER_RATIO
		transform.basis = transform.basis.rotated(Vector3.UP, randf() * PI * 2.0)
		
		grass_mesh.set_instance_transform(i, transform)
	
	var grass_instance = MultiMeshInstance3D.new()
	grass_instance.multimesh = grass_mesh
	grass_instance.material_override = create_grass_material()
	# grass_instance.position.y += 2
	
	return grass_instance

func get_random_grass() -> Mesh:
	return grass_models[randi() % grass_models.size()]

func create_grass_blade(height: float) -> ArrayMesh:
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	
	# Keep width constant but use passed-in height
	vertices.append(Vector3(-0.05, 0, 0))      # Bottom left
	vertices.append(Vector3(0.05, 0, 0))       # Bottom right
	vertices.append(Vector3(0.05, height, 0))  # Top right 
	vertices.append(Vector3(-0.05, height, 0)) # Top left
	
	for i in range(4):
		normals.append(Vector3(0, 0, 1))
	
	uvs.append(Vector2(0, 0))
	uvs.append(Vector2(1, 0))
	uvs.append(Vector2(1, 1))
	uvs.append(Vector2(0, 1))
	
	var indices = PackedInt32Array([
		0, 1, 2,
		0, 2, 3
	])
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

func create_grass_material() -> ShaderMaterial:
	var material = ShaderMaterial.new()
	material.shader = preload("res://Grass/grass.gdshader") # Make sure to adjust path
	
	material.set_shader_parameter("grass_color", Color(0.76, 0.70, 0.50))
	material.set_shader_parameter("wind_strength", wind_strength)
	material.set_shader_parameter("wind_speed", wind_speed)
	
	return material
