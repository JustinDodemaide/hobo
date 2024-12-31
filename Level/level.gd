extends Node3D

func _ready() -> void:
	# Generate level
	# Global.level = self
	$Ground.mesh = $LevelGen.generate_terrain_mesh()
	$Ground.create_trimesh_collision()
	$Player.position = Vector3($LevelGen.train_station.x * 10, 64, $LevelGen.train_station.y * 10)
	return
	await start_train()
	# Start timer
	pass # Replace with function body.
	
func generate_level():
	pass

func start_train():
	var player = load("res://Player/player.tscn").instantiate()
	player.add_to_group("Players")
	add_child(player)
	player.global_position = $Train/SpawnPoint.global_position

	var tween = create_tween()
	# tween_property(object: Object, property: NodePath, final_val: Variant, duration: float)
	tween.tween_property($Train,"position",$TrainStop.position,10).set_ease(Tween.EASE_OUT)
	await tween.finished
	var players = get_tree().get_nodes_in_group("Players")

func _process(delta: float) -> void:
	print($Player.position)
