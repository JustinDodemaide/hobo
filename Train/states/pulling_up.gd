extends State

func update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	var parent = get_parent()
	var tween = create_tween()
	#tween.tween_property($Sprite, "modulate", Color.RED, 1)
	tween.tween_property(parent,"progress_ratio",0.5,25).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	transition("Stopped")

func exit() -> void:
	pass

#https://easings.net/#easeOutSine
#function easeOutSine(x: number): number {
  #return Math.sin((x * Math.PI) / 2);
#}
