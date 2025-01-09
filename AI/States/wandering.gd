extends State

@onready var parent = $".."
@onready var timer = $WanderTimer as Timer
const MIN_WANDER_DISTANCE:int = 2
const MAX_WANDER_DISTANCE:int = 10

func enter(previous_state_path: String, data := {}) -> void:
	timer.start(randi_range(3,5))

func exit() -> void:
	timer.stop()

func _on_wander_timer_timeout() -> void:
	var x = randf_range(MIN_WANDER_DISTANCE,MAX_WANDER_DISTANCE)
	var z = randf_range(MIN_WANDER_DISTANCE,MAX_WANDER_DISTANCE)
	var lower_pos = Vector3(x, 0, z)
	var higher_pos = Vector3(x, 10, z)
	var closest_point_on_navmesh := NavigationServer3D.map_get_closest_point_to_segment(
		Global.level.get_world_3d().navigation_map,
		lower_pos,
		higher_pos
		)
	print(closest_point_on_navmesh)
	parent.transition("Walking", {"pos":closest_point_on_navmesh})
