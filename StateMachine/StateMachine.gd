class_name StateMachine extends Node

@export var initial_state: State = null

var state: State

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


func transition(target_state_name: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_name):
		printerr(owner.name + ": Trying to transition to state " + target_state_name + " but it does not exist.")
		return

	var previous_state := state.name
	state.exit()
	state = get_node(target_state_name)
	state.enter(previous_state, data)
