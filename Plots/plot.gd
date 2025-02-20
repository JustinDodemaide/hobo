class_name Plot
extends Node3D

enum DIRECTION {NORTH,SOUTH,EAST,WEST}

func _ready() -> void:
	#var rot = [Vector3(0,deg_to_rad(-90),0), Vector3(0,deg_to_rad(90),0)].pick_random()
	#if randi_range(0,1) == 0:
	#	rotate(Vector3(0,1,0),deg_to_rad(180))
	# the items dont match the rotation because their global position is set
	# before the rotation is (the items are children of the level not this)
	pass

func face_direction(direction:DIRECTION):
	match direction:
		DIRECTION.NORTH:
			pass
		DIRECTION.SOUTH:
			rotation = Vector3(0,180,0)
		DIRECTION.EAST:
			rotation = Vector3(0,-90,0)
		DIRECTION.WEST:
			rotation = Vector3(0,90,0)

signal player_entered_restricted_area(area:Area3D,player:Player)
func _on_restricted_area_area_entered(area: Area3D) -> void:
	var parent = area.get_parent()
	if parent is Player:
		emit_signal("player_entered_restricted_area", area, parent)

signal player_exited_restricted_area(area:Area3D,player:Player)
func _on_restricted_area_area_exited(area: Area3D) -> void:
	var parent = area.get_parent()
	if parent is Player:
		emit_signal("player_exited_restricted_area", area, parent)
