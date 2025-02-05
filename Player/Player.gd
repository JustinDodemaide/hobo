extends CharacterBody3D
class_name Player

@export var ui:Control

var SPEED = 50.0
var JUMP_VELOCITY = 7

const MAX_HEALTH:int = 100
var current_health:int = MAX_HEALTH

func _ready() -> void:
	Global.players.append(self)

var fast_mode:bool = true
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("Esc"):
		get_tree().quit()
	if Input.is_action_pressed("equal"):
		fast_mode = !fast_mode
		if fast_mode:
			SPEED = 50.0
			JUMP_VELOCITY = 7
		else:
			SPEED = 5.0
			JUMP_VELOCITY = 3
	handle_movement(delta)
	$CanvasLayer/FPS.text = str(Engine.get_frames_per_second())


func handle_movement(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("A", "D", "W", "S")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
