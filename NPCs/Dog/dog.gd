extends CharacterBody3D

@export var initial_state:State
var state

@onready var nav:NavigationAgent3D = $NavigationAgent3D
@onready var sprite:AnimatedSprite3D = $AnimatedSprite3D

var moving:bool = false
var tracking_target:Variant
var speed:float = 5.0

func _ready() -> void:
	await owner.ready
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
	
	var previous_state = state.name
	$Label3D.text = target_state_name
	state.exit()
	state = get_node(target_state_name)
	state.enter(previous_state, data)

func _on_sensors_updated() -> void:
	pass

func player_entered_restricted_area(area, player):
	print("uhhhhh")
	#if $Sensors.get_seen_players().has(player):
	transition("Alert", {"track":player})

func player_exited_restricted_area(area, player):
	#if $Sensors.get_seen_players().has(player):
	transition("Wandering")

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
	# look_at(next_path_position)
	move_and_slide()

func _on_navigation_agent_3d_target_reached() -> void:
	if state.has_method("target_reached"):
		state.target_reached()
