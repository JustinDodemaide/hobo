extends State

@onready var player = $"../.."
var jump_velocity:float = 4.5
var jumped:bool = false

func physics_update(_delta: float) -> void:
	if not jumped:
		return
	# Wait until the player hits the ground again
	player.move_and_slide()

	if player.is_on_floor():
		if Input.get_vector("A", "D", "W", "S") != Vector2.ZERO:
			transition("Moving")
		else:
			transition("Idle")
	#if player.velocity.y == 0:
		#transition("Idle")

func enter(_previous_state: String, _data := {}) -> void:
	get_parent().model.play_animation("jump")

func exit() -> void:
	jumped = false

func _on_character_model_jumped() -> void:
	jumped = true
	player.velocity.y += jump_velocity
