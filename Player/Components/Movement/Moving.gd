extends State
@export var speed:float = 15#5.0
@export var acceleration : float = 10.0

func physics_update(delta: float) -> void:
	var player = get_parent().player
	if Input.is_action_pressed("Space") and player.is_on_floor(): #and !low_ceiling:
		transition("Jumping")
		return
	
	var input_dir = Input.get_vector("A", "D", "W", "S")
	
	# Get the camera reference (adjust the path to your camera node)
	var camera = get_viewport().get_camera_3d()
	
	# Calculate camera-relative direction
	var cam_basis = camera.global_transform.basis
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	direction = cam_basis * direction
	direction.y = 0  # Ensure movement is on the XZ plane
	direction = direction.normalized()
	
	if input_dir != Vector2.ZERO:
		var new_rot = atan2(direction.x, direction.z)
		var current_rot = get_parent().model.rotation.y
		get_parent().model.rotation.y = lerp_angle(current_rot, new_rot, 0.25)
	
	player.move_and_slide()
	if player.is_on_floor():
		player.velocity.x = lerp(player.velocity.x, direction.x * speed, acceleration * delta)
		player.velocity.z = lerp(player.velocity.z, direction.z * speed, acceleration * delta)
	
	var current_speed = Vector3.ZERO.distance_to(player.get_real_velocity())
	if current_speed <= 0.25 and input_dir == Vector2.ZERO:
		transition("Idle")
		return
	
	get_parent().model.get_node("AnimationPlayer").speed_scale = current_speed * 0.25

func enter(_previous_state: String, _data := {}) -> void:
	get_parent().model.play_animation("walk")

func exit() -> void:
	get_parent().model.get_node("AnimationPlayer").speed_scale = 1.0
