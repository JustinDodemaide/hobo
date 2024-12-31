extends State

var parent
func update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	var parent = get_parent()
	var tween = create_tween()
	tween.tween_property(parent,"progress_ratio",1.0,5).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	transition("PullingUp")

func exit() -> void:
	pass
