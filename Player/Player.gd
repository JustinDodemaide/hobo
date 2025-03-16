extends CharacterBody3D
class_name Player

@export var ui:Control
@export var inventory_component:Node
var held_item:Item = null

func _ready() -> void:
	Global.players.append(self)

var fast_mode:bool = true
func _physics_process(delta: float) -> void:
	print(global_position)
	
	if Input.is_action_pressed("Esc"):
		get_tree().quit()
	#if Input.is_action_pressed("equal"):
		#fast_mode = !fast_mode
		#if fast_mode:
			#SPEED = 50.0
			#JUMP_VELOCITY = 7
		#else:
			#SPEED = 5.0
			#JUMP_VELOCITY = 3
	#handle_movement(delta)
	$CanvasLayer/FPS.text = str(Engine.get_frames_per_second())

#region Movement
var SPEED = 50.0
var JUMP_VELOCITY = 7
func handle_movement(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("ui_accept"):# and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Calculate effect of player input
	var input_dir := Input.get_vector("A", "D", "W", "S")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Determine how much control the player has (less when under external force)
	var control_factor = 1.0
	if external_velocity.length() > 0.01:
		control_factor = control_reduction
	
	if direction:
		velocity.x = direction.x * SPEED * control_factor
		velocity.z = direction.z * SPEED * control_factor
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * control_factor)
		velocity.z = move_toward(velocity.z, 0, SPEED * control_factor)
#endregion

#region Apply Force
	if external_velocity != Vector3.ZERO:
		velocity += external_velocity
		
		# Decay external forces
		external_velocity *= force_decay
		if external_velocity.length() < 0.01:
			external_velocity = Vector3.ZERO
	
	move_and_slide()

var external_velocity = Vector3.ZERO
var force_decay = 0.9  # How quickly forces diminish each frame
var control_reduction = 0.3  # Player retains 30% control when under external force
func apply_force(force_vector):
	external_velocity += force_vector

func apply_force_from_position(source_position, force_strength):
	var direction = global_position - source_position
	direction.y = clamp(direction.y, -0.5, 1.0)
	
	apply_force(direction.normalized() * force_strength)
#endregion
