extends Node3D

func init(highest,lowest):
	# We don't want the foundation to be floating, so we make sure its tall
	# enough to go into the ground, even if its at the highest point of the
	# terrain
	var difference =  highest - lowest
	$MeshInstance3D.mesh.size.y = difference
	$MeshInstance3D.position.y -= difference / 2


signal player_entered_restricted_area(player:Player)
func _on_restricted_area_area_entered(area: Area3D) -> void:
	var parent = area.get_parent() 
	if parent is Player:
		emit_signal("player_entered_restricted_area", parent)
