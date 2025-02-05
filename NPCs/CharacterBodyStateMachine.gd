class_name CharacterBodyStateMachine extends CharacterBody3D

@export var initial_state: State = null

var state: State

var moving:bool = false
var tracking_target:Variant
var speed:float = 5.0
@onready var nav:NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	state = initial_state
	transition(state.name)

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)
	if moving:
		move(delta)


func transition(target_state_name: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_name):
		printerr(owner.name + ": Trying to transition to state " + target_state_name + " but it does not exist.")
		return

	var previous_state := state.name
	state.exit()
	state = get_node(target_state_name)
	state.enter(previous_state, data)

func track(target:Variant) -> void:
	tracking_target = target
	moving = true

func stop_tracking() -> void:
	tracking_target = null
	moving = false

func move_to(target:Vector3) -> void:
	tracking_target = null
	nav.set_target_position(target)
	moving = true

func move(delta):
	if tracking_target:
		nav.set_target_position(tracking_target.global_position)
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
	if nav.is_navigation_finished():
			return
	var next_path_position: Vector3 = nav.get_next_path_position()
	velocity = (next_path_position - global_position).normalized() * speed
	look_at(next_path_position)
	move_and_slide()

func _on_navigation_agent_3d_target_reached() -> void:
	if state.has_method("target_reached"):
		state.target_reached()
	if tracking_target == null:
		moving = false
