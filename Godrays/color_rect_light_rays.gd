extends ColorRect

var light : DirectionalLight3D
@export var camera : Camera3D

func _ready():
	light = Global.level.get_node("DirectionalLight3D")
	camera.get_node("GodRayRemote").remote_path = $"../GodRayStuff/SubViewportContainer/SubViewport/Camera3D_Viewport"

func _process(_delta: float) -> void:
	var pos = camera.unproject_position(camera.global_position - (-light.global_basis.z.normalized()))   
	material.set_shader_parameter("light_source_pos", pos)
	material.set_shader_parameter("light_source_dir", -light.global_basis.z)
	material.set_shader_parameter("camera_dir", -camera.global_basis.z)
