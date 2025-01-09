extends Node3D

func init(highest,lowest):
	# We don't want the foundation to be floating, so we make sure its tall
	# enough to go into the ground, even if its at the highest point of the
	# terrain
	var difference =  highest - lowest
	$MeshInstance3D.mesh.size.y = difference
	$MeshInstance3D.position.y -= difference / 2
