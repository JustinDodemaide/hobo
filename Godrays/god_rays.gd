extends Node

func _ready() -> void:
	var player = get_parent()
	var color_rect = $Control/ColorRect_LightRays
	color_rect.light = Global.level.get_node("DirectionalLight3D")
	color_rect.camera = player.get_node("Camera3D")
	
	var remote:RemoteTransform3D = RemoteTransform3D.new()
	remote.update_scale = false
	remote.remote_path = "../GodRays/SubViewportContainer/SubViewport/Camera3D_Viewport"
	player.get_node("Camera3D").add_child(remote)
