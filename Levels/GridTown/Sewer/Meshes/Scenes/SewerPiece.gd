extends Node3D
class_name SewerPiece

@export var spawn:Marker3D

	#"vertical": Vector2i(1, 0),
	#"horizontal": Vector2i(2, 0),
	#"corner_ne": Vector2i(3, 0),
	#"corner_es": Vector2i(4, 0),
	#"corner_sw": Vector2i(5, 0),
	#"corner_wn": Vector2i(6, 0),
	#"t_junction_n": Vector2i(7, 0),
	#"t_junction_e": Vector2i(8, 0),
	#"t_junction_s": Vector2i(9, 0),
	#"t_junction_w": Vector2i(10, 0),
	#"cross": Vector2i(11, 0),
	#"dead_end_n": Vector2i(12, 0),
	#"dead_end_e": Vector2i(13, 0),
	#"dead_end_s": Vector2i(14, 0),
	#"dead_end_w": Vector2i(15, 0)

# NORTH IS POSITIVE X
var direction
func orient(s:String):
	if has_node("Label3D"):
		$Label3D.text = s
	
	match s:
		"horizontal":rotation_degrees = Vector3(0,90,0)
		
		"t_junction_n":rotation_degrees = Vector3(0,-90,0)
		"t_junction_e":rotation_degrees = Vector3(0,180,0)
		"t_junction_s":rotation_degrees = Vector3(0,90,0)
		"t_junction_w":rotation_degrees = Vector3(0,0,0)
		
		"corner_ne":rotation_degrees = Vector3(0,-90 + 180,0)
		"corner_es":rotation_degrees = Vector3(0,180 + 180,0)
		"corner_sw":rotation_degrees = Vector3(0,90 + 180,0)
		"corner_wn":rotation_degrees = Vector3(0,0 + 180,0)
		
		"dead_end_n":rotation_degrees = Vector3(0,-180 + 180,0)
		"dead_end_e":rotation_degrees = Vector3(0,90 + 180,0)
		"dead_end_s":rotation_degrees = Vector3(0,-90 + 180,0)
		"dead_end_w":rotation_degrees = Vector3(0,90 + 180,0)

func _ready() -> void:
	if has_node("SewerExit"):
		#Global.level.get_node("LevelGen").sewer_entrances.pick_random().connect_exit($SewerExit)
		Global.level.get_node("LevelGen").sewer_exits.append($SewerExit)
