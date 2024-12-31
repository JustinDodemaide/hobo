extends RayCast3D

@export var raycast_length:float = 2
var parent
var the_object_last_underneath_us = null
var previous_global_position: Vector3 = global_position

func _ready() -> void:
	parent = get_parent()
	target_position *= raycast_length

func _process(delta: float) -> void:
	handle_moving_objects()

func handle_moving_objects() -> void:
	# we need to get the difference between where the object was and where it is, then add that to the player's pos
	# but if this is the first time we're interacting with this object, we're not gonna know where it was
	var the_object_underneath_us = get_collider()
	if the_object_underneath_us == null:
		the_object_last_underneath_us = null
		return
	if the_object_underneath_us != the_object_last_underneath_us:
		the_object_last_underneath_us = the_object_underneath_us
		previous_global_position = the_object_underneath_us.global_position
	var movement_delta = the_object_underneath_us.global_position - previous_global_position
	previous_global_position = the_object_underneath_us.global_position
	parent.global_position += movement_delta
