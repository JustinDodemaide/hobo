extends State

func update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	$Timer.start(2)

func exit() -> void:
	pass

func _on_timer_timeout() -> void:
	transition("Leaving")
