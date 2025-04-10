extends MeshInstance3D

func connect_icons(icon1, icon2):
	var pos1_global = icon1.global_position
	var pos2_global = icon2.global_position

	var midpoint_x = (pos1_global.x + pos2_global.x) / 2.0
	var midpoint_z = (pos1_global.z + pos2_global.z) / 2.0

	global_position = Vector3(midpoint_x, global_position.y, midpoint_z)

	var dir_x = pos2_global.x - pos1_global.x
	var dir_z = pos2_global.z - pos1_global.z

	if abs(dir_x) < 0.0001 and abs(dir_z) < 0.0001:
		return

	var angle_rad = atan2(dir_x, dir_z)
	rotation.y = angle_rad
