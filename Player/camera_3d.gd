extends Camera3D

# Camera sensitivity settings
@export var mouse_sensitivity: float = 0.005
@export var controller_sensitivity: float = 0.05

# Camera limits
@export var max_up_aim_angle: float = 90.0
@export var max_down_aim_angle: float = 90.0
@export var limit_angle: bool = true

# Smoothing
@export var mouse_smoothing: bool = true
@export var smoothing_speed: float = 20.0

# Head bobbing
@export var enable_head_bobbing: bool = true
@export var bob_frequency: float = 2.0
@export var bob_amplitude: float = 0.08
@export var bob_max_travel: float = 0.05

# FOV settings
@export var base_fov: float = 75.0
@export var fov_change_speed: float = 4.0
@export var sprint_fov_multiplier: float = 1.1

# Internal variables
var camera_rotation_x: float = 0.0
var camera_rotation_y: float = 0.0
var target_rotation_x: float = 0.0
var target_rotation_y: float = 0.0
var bob_time: float = 0.0
var bob_offset: Vector3 = Vector3.ZERO
var original_position: Vector3
var parent_node: Node3D
var player_velocity: Vector3 = Vector3.ZERO
var target_fov: float

func _ready():
	# Initialize the camera
	original_position = position
	target_fov = base_fov
	fov = base_fov
	
	# Get the parent node (likely the player)
	parent_node = get_parent()
	
	# Capture the mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		target_rotation_y -= event.relative.x * mouse_sensitivity
		target_rotation_x -= event.relative.y * mouse_sensitivity
		
		if limit_angle:
			# Convert to degrees for easier handling
			var deg_x = rad_to_deg(target_rotation_x)
			deg_x = clamp(deg_x, -max_down_aim_angle, max_up_aim_angle)
			target_rotation_x = deg_to_rad(deg_x)
	
	# Toggle mouse capture with Escape
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	# Update camera rotation with smoothing if enabled
	if mouse_smoothing:
		camera_rotation_x = lerp(camera_rotation_x, target_rotation_x, delta * smoothing_speed)
		camera_rotation_y = lerp(camera_rotation_y, target_rotation_y, delta * smoothing_speed)
	else:
		camera_rotation_x = target_rotation_x
		camera_rotation_y = target_rotation_y
	
	# Apply rotation - important to reset between rotations
	transform.basis = Basis()
	# First rotate around Y (left/right)
	rotate_object_local(Vector3.UP, camera_rotation_y)
	# Then rotate around local X (up/down)
	rotate_object_local(Vector3.RIGHT, camera_rotation_x)
	
	# Handle head bobbing
	if enable_head_bobbing and parent_node.has_method("get_real_velocity"):
		player_velocity = parent_node.get_real_velocity()
		var speed = Vector2(player_velocity.x, player_velocity.z).length()
		
		# Only bob when moving on ground
		if speed > 0.1 and parent_node.is_on_floor():
			bob_time += delta * bob_frequency * (speed / 5.0)
			
			# Calculate head bob offset
			var bob_y = sin(bob_time) * bob_amplitude
			var bob_x = cos(bob_time / 2.0) * bob_amplitude / 2.0
			
			bob_offset.y = lerp(bob_offset.y, bob_y, delta * smoothing_speed)
			bob_offset.x = lerp(bob_offset.x, bob_x, delta * smoothing_speed)
			
			# Limit maximum travel
			bob_offset.y = clamp(bob_offset.y, -bob_max_travel, bob_max_travel)
			bob_offset.x = clamp(bob_offset.x, -bob_max_travel, bob_max_travel)
		else:
			# Return to neutral position when not moving
			bob_offset = bob_offset.lerp(Vector3.ZERO, delta * smoothing_speed)
		
		# Apply bob offset
		position = original_position + bob_offset
	
	# Handle FOV changes for sprinting
	if parent_node.has_method("is_sprinting") and parent_node.is_sprinting():
		target_fov = base_fov * sprint_fov_multiplier
	else:
		target_fov = base_fov
	
	# Apply FOV change smoothly
	fov = lerp(fov, target_fov, delta * fov_change_speed)

# This function allows other scripts to force a rotation (e.g., when respawning)
func _set_rotation(new_rotation_x: float, new_rotation_y: float):
	target_rotation_x = new_rotation_x
	target_rotation_y = new_rotation_y
	camera_rotation_x = new_rotation_x
	camera_rotation_y = new_rotation_y
