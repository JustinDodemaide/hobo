extends MeshInstance3D

func connect_icons(icon1, icon2):
	var pos1 = icon1.position
	var pos2 = icon2.position

	var midpoint_x = (pos1.x + pos2.x) / 2.0
	var midpoint_z = (pos1.z + pos2.z) / 2.0

	position = Vector3(midpoint_x, position.y, midpoint_z)

	var dir_x = pos2.x - pos1.x
	var dir_z = pos2.z - pos1.z

	if abs(dir_x) < 0.0001 and abs(dir_z) < 0.0001:
		return

	var angle_rad = atan2(dir_x, dir_z)
	rotation.y = angle_rad
