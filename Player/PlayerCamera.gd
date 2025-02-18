# https://github.com/tavurth/godot-simple-fps-camera/blob/master/player/Camera.gd
extends Camera3D

var enabled:bool = true

@onready var player = get_parent()

## Increase this value to give a slower turn speed
const DEFAULT_TURN_SPEED:int = 200
var camera_turn_speed = DEFAULT_TURN_SPEED

func _ready():
	## Tell Godot that we want to handle input
	set_process_input(true)

func look_updown_rotation(new_rotation = 0):
	"""
	Returns a new Vector3 which contains only the x direction
	We'll use this vector to compute the final 3D rotation later
	"""
	var toReturn = self.get_rotation() + Vector3(new_rotation, 0, 0)

	##
	## We don't want the player to be able to bend over backwards
	## neither to be able to look under their arse.
	## Here we'll clamp the vertical look to 90° up and down
	toReturn.x = clamp(toReturn.x, PI / -2, PI / 2)

	return toReturn

func look_leftright_rotation(new_rotation = 0):
	"""
	Returns a new Vector3 which contains only the y direction
	We'll use this vector to compute the final 3D rotation later
	"""
	return player.get_rotation() + Vector3(0, new_rotation, 0)

func _input(event):
	"""
	First person camera controls
	"""
	if not enabled:
		return
	
	##
	## We'll only process mouse motion events
	if not event is InputEventMouseMotion:
		return

	##
	## We'll use the parent node "Player" to set our left-right rotation
	## This prevents us from adding the x-rotation to the y-rotation
	## which would result in a kind of flight-simulator camera
	player.set_rotation(look_leftright_rotation(event.relative.x / -camera_turn_speed))

	##
	## Now we can simply set our y-rotation for the camera, and let godot
	## handle the transformation of both together
	self.set_rotation(look_updown_rotation(event.relative.y / -camera_turn_speed))

func _enter_tree():
	"""
	Hide the mouse when we start
	"""
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _leave_tree():
	"""
	Show the mouse when we leave
	"""
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
