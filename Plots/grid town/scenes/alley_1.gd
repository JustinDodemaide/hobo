extends Node3D

func _ready() -> void:
	make_mimic()
	return
	if randf_range(1,10) == 7:
		make_mimic()

func make_mimic():
	$MimicSensor.monitoring = true

func _on_mimic_sensor_area_entered(area: Area3D) -> void:
	var parent = area.get_parent()
	if parent is Player:
		var bum = load("res://NPCs/Bum/Bum.tscn").instantiate()
		bum.position = $trashcan.global_position
		$trashcan.queue_free()
		Global.level.add_child(bum)
		print(bum.global_position)
		bum.alerted_by(parent)
		$MimicSensor.queue_free()
