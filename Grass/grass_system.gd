class_name GrassSystem

var grass_density: float = 1.0
var wind_strength: float = 0.2
var wind_speed: float = 1.0
var grass_height_range := Vector2(0.3, 0.5)

func create_grass_system(level_gen, density: float = 1.0, w_strength: float = 0.2, w_speed: float = 1.0) -> MultiMeshInstance3D:
	grass_density = density
	wind_strength = w_strength
	wind_speed = w_speed
	
	var blade = create_grass_blade()
	var num_blades = round(level_gen.WIDTH * level_gen.HEIGHT * grass_density)
	
	var grass_mesh = MultiMesh.new()
	grass_mesh.transform_format = MultiMesh.TRANSFORM_3D
	grass_mesh.mesh = blade
	grass_mesh.instance_count = num_blades
	
	#var distribution_noise = FastNoiseLite.new()
	#distribution_noise.seed = randi()
	#distribution_noise.frequency = 0.1
	
	for i in num_blades:
		var transform = Transform3D()
		
		var x = randi_range(0, level_gen.WIDTH - 1)
		var y = randi_range(0, level_gen.HEIGHT - 1)
		# Need to 1. Account for the terrain mesh being scaled up (do that
		# after we get the elevation, of course) and 2. Offset them a little
		# or else they're going to be arranged in a grid, all the same
		# distance from each other
		# Ok ok so - we're getting the elevation at a point in the grid, then
		# setting the blade's elevation, then offsetting the blade a bit. So it
		# still has the old elevation despite being in a different place
		# So we need to get the correct elevation for the new offset place
		# If we were just offsetting x, we'd get the elevation of the initial pos,
		# the elevation of the pos we're moving closer toward, make a linear function,
		# then plug in the offset x to get the correct height
		# Issue is we're moving the y too. Could just be the same thing
		var initial_elevation = level_gen.get_height_at(Vector2(x,y))
		var next_elevation = level_gen.get_height_at(Vector2(x + 1,y))
		var slope = initial_elevation - next_elevation # The distance between them is always 1
		x += randi_range(0,level_gen.TILE_SIZE) * level_gen.TILE_SIZE # Get the offset, scaled up x value
		# y = mx + b
		var z = slope * x + initial_elevation

		#y *= level_gen.TILE_SIZE
		#y += randi_range(0,level_gen.TILE_SIZE)

		
		
		#var noise_val = distribution_noise.get_noise_2d(grid_x, grid_y)
		#if noise_val < -0.2: # Made this more permissive for better coverage
		#	continue
		
		# Set pos and rotation, scale kept messing up the elevation so forgoing that
		var pos = Vector3(x,z,y)
		transform.origin = pos
		#transform.basis = transform.basis.rotated(Vector3.UP, randf() * PI * 2.0)
		
		grass_mesh.set_instance_transform(i, transform)
	
	var grass_instance = MultiMeshInstance3D.new()
	grass_instance.multimesh = grass_mesh
	grass_instance.material_override = create_grass_material()
	# grass_instance.position.y += 2
	
	return grass_instance

func create_grass_blade() -> ArrayMesh:
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	
	vertices.append(Vector3(-0.05, 0, 0))
	vertices.append(Vector3(0.05, 0, 0))
	vertices.append(Vector3(0.05, 0.5, 0))
	vertices.append(Vector3(-0.05, 0.5, 0))
	
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
