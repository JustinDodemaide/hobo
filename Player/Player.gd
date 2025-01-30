extends CharacterBody3D
class_name Player

var SPEED = 50.0
var JUMP_VELOCITY = 7

var the_object_last_underneath_us = null
var previous_global_position: Vector3 = global_position

func _ready() -> void:
	Global.players.append(self)

func _physics_process(delta: float) -> void:
	# print(global_position)
	
	if Input.is_action_pressed("Esc"):
		get_tree().quit()
	if Input.is_action_pressed("equal"):
		if SPEED == 5.0:
			SPEED = 50.0
			JUMP_VELOCITY = 7
		else:
			SPEED = 5.0
			JUMP_VELOCITY = 3
	handle_movement(delta)
	# handle_moving_objects()
	# handle_item_raycast()
	$CanvasLayer/FPS.text = str(Engine.get_frames_per_second())
	#if $MovingObjectRaycast.is_colliding():
		#reparent($MovingObjectRaycast.get_collider())
	#else:
		#reparent(Global.level)
	#$CanvasLayer/Label.text = get_parent().name

func handle_movement(delta) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"): #and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("A", "D", "W", "S")
	#var input_dir := Input.get_vector("D", "A", "S", "W")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

func handle_moving_objects() -> void:
	# we need to get the difference between where the object was and where it is, then add that to the player's pos
	# but if this is the first time we're interacting with this object, we're not gonna know where it was
	var the_object_underneath_us = $MovingObjectRaycast.get_collider()
	if the_object_underneath_us == null:
		the_object_last_underneath_us = null
		return
	if the_object_underneath_us != the_object_last_underneath_us:
		the_object_last_underneath_us = the_object_underneath_us
		previous_global_position = the_object_underneath_us.global_position
	var movement_delta = the_object_underneath_us.global_position - previous_global_position
	previous_global_position = the_object_underneath_us.global_position
	global_position += movement_delta

#func handle_item_raycast() -> void:
	#var collider = $Camera3D/ItemRaycast.get_collider()
	#if collider:
		#collider = collider.get_parent()
	#if collider is Item:
		#$Camera3D/HandIcon.visible = true
		#print("looking at item")
		#return
	#$Camera3D/HandIcon.visible = false
