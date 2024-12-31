extends StateMachine
class_name Train

@export var spawn_point:Marker3D

func _ready() -> void:
	state = $PullingUp
	transition("PullingUp")

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func _process(delta: float) -> void:
	state.update(delta)

func _physics_process(delta: float) -> void:
	state.physics_update(delta)

func transition(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return

	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)

func add_players(level):
	var player = load("res://Player/Player.tscn").instantiate()
	level.add_child(player)
	player.global_transform = $SpawnPoint.global_transform
