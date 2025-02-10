class_name FoliageSystem

var density: float = 1.0
var height_range := Vector2(0.3, 0.5)

var wind_strength: float = 0.2
var wind_speed: float = 1.0
var model_paths:Array[String] = [
"res://DesertPlants/CactusFlowers_2.obj",
"res://DesertPlants/CactusFlowers_3.obj",
"res://DesertPlants/CactusFlowers_4.obj",
"res://DesertPlants/CactusFlowers_5.obj",
"res://DesertPlants/CactusFlower_1.obj",

"res://DesertPlants/Cactus_1.obj",
"res://DesertPlants/Cactus_2.obj",
"res://DesertPlants/Cactus_3.obj",
"res://DesertPlants/Cactus_4.obj",
"res://DesertPlants/Cactus_5.obj",
]

func create_foliage(mesh:MeshInstance3D, _density:float = 1.0, w_strength:float = 0.2, w_speed:float = 1.0) -> MultiMeshInstance3D:
	density = _density
	wind_strength = w_strength
	wind_speed = w_speed
	
	var height = randf_range(height_range.x, height_range.y)
	var num_objects = round(mesh.size.x * mesh.size.y * density)
	
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = load(model_paths.pick_random())
	multimesh.instance_count = num_objects
	
	for i in num_objects:
		var transform = Transform3D()
		
		var pos = Vector2(randi_range(0, level_gen.WIDTH - 2), randi_range(0, level_gen.LENGTH - 2))
		var displacement = Vector2(randf_range(0, 1), randf_range(0, 1))
		
		# Use bilinear interpolation to get the height at the displaced pos
		# Get heights at the four corners of our grid cell
		var y00 = level_gen.get_height(Vector2(pos.x, pos.y))        # Bottom left
		var y10 = level_gen.get_height(Vector2(pos.x + 1, pos.y))     # Bottom right
		var y01 = level_gen.get_height(Vector2(pos.x, pos.y + 1))   # Top left
		var y11 = level_gen.get_height(Vector2(pos.x + 1, pos.y + 1)) # Top right

		var dx = displacement.x
		var dy = displacement.y
		# First interpolate in x direction along both rows
		var y0 = y00 * (1 - dx) + y10 * dx  # Bottom row
		var y1 = y01 * (1 - dx) + y11 * dx  # Top row

		# Then interpolate between those results in y direction
		var z = y0 * (1 - dy) + y1 * dy
		
		# Set pos and rotation, scale kept messing up the elevation so forgoing that
		pos += displacement
		transform.origin = Vector3(pos.x, z, pos.y) * level_gen.TILE_TO_METER_RATIO
		transform.basis = transform.basis.rotated(Vector3.UP, randf() * PI * 2.0)
		
		multimesh.set_instance_transform(i, transform)
	
	var multimesh_instance = MultiMeshInstance3D.new()
	multimesh_instance.multimesh = multimesh
	multimesh_instance.material_override = create_grass_material()
	
	return multimesh_instance

func create_grass_material() -> ShaderMaterial:
	var material = ShaderMaterial.new()
	material.shader = preload("res://Grass/grass.gdshader")
	
	material.set_shader_parameter("grass_color", Color(0.76, 0.70, 0.50))
	material.set_shader_parameter("wind_strength", wind_strength)
	material.set_shader_parameter("wind_speed", wind_speed)
	
	return material
