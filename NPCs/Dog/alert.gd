extends State

@onready var parent = $".."

func enter(previous_state: String, data := {}) -> void:
	parent.tracking_target = data.track
	alert()
	parent.moving = true

func exit() -> void:
	parent.tracking_target = null

func target_reached() -> void:
	parent.moving = false
	alert()

func alert():
	parent.sprite.play("alert")

func _on_animated_sprite_3d_animation_finished() -> void:
	parent.moving = true
