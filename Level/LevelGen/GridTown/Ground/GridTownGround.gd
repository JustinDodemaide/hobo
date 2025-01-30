extends Node3D

func init(gen) -> void:
	scale.x = gen.WIDTH * gen.TILE_TO_METER_RATIO
	scale.z = gen.LENGTH * gen.TILE_TO_METER_RATIO
	post_signs()

func _on_area_3d_area_entered(area: Area3D) -> void:
	print("player OOB")

func post_signs():
	for marker in $signs.get_children():
		var sprite = Sprite3D.new()
		sprite.global_position = marker.global_position
		sprite.texture = load("res://icon.svg")
		Global.level.add_child(sprite)
		marker.queue_free()
