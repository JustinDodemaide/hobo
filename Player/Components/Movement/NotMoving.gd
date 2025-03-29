extends State

@export var sm:StateMachine

func handle_input(_event: InputEvent) -> void:
	pass

func physics_update(delta: float) -> void:
	if Input.is_action_pressed("Space") and sm.player.is_on_floor(): #and !low_ceiling:
		transition("Jumping")
		return
		
	var input_dir = Input.get_vector("A", "D", "W", "S")
	if input_dir != Vector2.ZERO:
		transition("Moving")

func enter(_previous_state: String, _data := {}) -> void:
	print("idle")
	sm.model.play_animation("idle")
	var tween = create_tween()
	tween.tween_interval(0.01)
	await tween.finished

func exit() -> void:
	pass
