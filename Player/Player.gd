extends CharacterBody3D
class_name Player

@export var ui:Control
@export var inventory_component:Node
var held_item:Item = null

func _ready() -> void:
	Global.players.append(self)

func enable():
	$Camera3D.enable()
	$CanvasLayer.process_mode = Node.PROCESS_MODE_INHERIT
	$CanvasLayer.visible = true

func disable():
	$Camera3D.disable()
	$CanvasLayer.process_mode = Node.PROCESS_MODE_DISABLED
	$CanvasLayer.visible = false

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("Esc"):
		get_tree().quit()
	$CanvasLayer/FPS.text = str(Engine.get_frames_per_second())

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
