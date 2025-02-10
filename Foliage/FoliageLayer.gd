extends MultiMeshInstance3D

@export var ground:MeshInstance3D
@export var model:Mesh
@export var material:Material
@export_range(0, 1) var density:float = 0.001 # What percentage of the total square meters has a plant on it

func _ready() -> void:
	if model == null:
		push_error("foliage layer doesn't have model")
	
	var accumulated_scale = Vector3.ONE
	var current_node = ground
	while current_node:
		if current_node is Window:
			break
		accumulated_scale *= current_node.scale
		current_node = current_node.get_parent()
	
	var size = Vector2(ground.mesh.size.x * accumulated_scale.x, ground.mesh.size.y * accumulated_scale.z)
	var num_objects:int = size.x * size.y * density
	
	var mesh = MultiMesh.new()
	mesh.transform_format = MultiMesh.TRANSFORM_3D
	mesh.mesh = model
	mesh.instance_count = num_objects
	for i in num_objects:
		var instance_transform = Transform3D()
		var x = randi_range(0, size.x)
		var z = randi_range(0, size.y)
		var height = 1
		instance_transform.origin = Vector3(x, height, z)
		mesh.set_instance_transform(i, instance_transform)
	multimesh = mesh
	
	if material:
		material_override = material
	
	# Need to free all the init parameters
	set_script(null)
	
