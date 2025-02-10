extends Node3D


var bear = load("res://NPCs/Bear/Bear.tscn").instantiate()
signal player_oob(player)

func init(gen) -> void:
	scale.x = gen.WIDTH * gen.TILE_TO_METER_RATIO
	scale.z = gen.LENGTH * gen.TILE_TO_METER_RATIO
	post_signs()
	Global.level.add_child(bear)
	foliage()

func _on_area_3d_area_entered(area: Area3D) -> void:
	var parent = area.get_parent()
	if parent is Player:
		bear.pursue(parent)

func post_signs():
	for marker in $signs.get_children():
		var sprite = Sprite3D.new()
		# sprite.global_position = marker.global_position
		sprite.texture = load("res://icon.svg")
		Global.level.add_child(sprite)
		marker.queue_free()

func foliage() -> void:
	# gotta add the foliage as a child of the level so the scale isn't applied
	var foliage_layer = load("res://Foliage/FoliageLayer.tscn").instantiate()
	foliage_layer.ground = $left
	foliage_layer.model = load("res://Grass/Grass_Short.obj")
	foliage_layer.material_override = create_grass_material()
	print($left.global_position)
	foliage_layer.global_position = Vector3(-350, -1, -350)
	Global.level.add_child(foliage_layer)

	foliage_layer = load("res://Foliage/FoliageLayer.tscn").instantiate()
	foliage_layer.ground = $right
	foliage_layer.model = load("res://Grass/Grass_Short.obj")
	foliage_layer.material_override = create_grass_material()
	print($left.global_position)
	foliage_layer.global_position = Vector3(350, -1, -350)
	Global.level.add_child(foliage_layer)
	
	foliage_layer = load("res://Foliage/FoliageLayer.tscn").instantiate()
	foliage_layer.ground = $down
	foliage_layer.model = load("res://Grass/Grass_Short.obj")
	foliage_layer.material_override = create_grass_material()
	print($left.global_position)
	foliage_layer.global_position = Vector3(1, -1, 350)
	Global.level.add_child(foliage_layer)
	
	foliage_layer = load("res://Foliage/FoliageLayer.tscn").instantiate()
	foliage_layer.ground = $down
	foliage_layer.model = load("res://Grass/Grass_Short.obj")
	foliage_layer.material_override = create_grass_material()
	print($left.global_position)
	foliage_layer.global_position = Vector3(1, -1, -350)
	Global.level.add_child(foliage_layer)

func create_grass_material() -> ShaderMaterial:
	var material = ShaderMaterial.new()
	material.shader = preload("res://Grass/grass.gdshader")
	
	material.set_shader_parameter("grass_color", Color(0.76, 0.70, 0.50))
	material.set_shader_parameter("wind_strength", 0.2)
	material.set_shader_parameter("wind_speed", 1)
	
	return material
