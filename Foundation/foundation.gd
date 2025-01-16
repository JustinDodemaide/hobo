extends Node3D

var building_dimensions = ["ONExONE", "TWOxONE", "TWOxTWO"]
const one_by_one_buildings = []
const two_by_one_buildings = ["res://store.glb"]

var spaces = [[null, null],
			  [null,null]]

func init(highest,lowest):
	# We don't want the foundation to be floating, so we make sure its tall
	# enough to go into the ground, even if its at the highest point of the
	# terrain
	var difference =  highest - lowest
	$MeshInstance3D.mesh.size.y = difference
	$MeshInstance3D.position.y -= difference / 2

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

func place_buildings():
	var first_building = building_dimensions.pick_random()
	if first_building == "ONExONE":
		spaces.pick_random().pick_random()
