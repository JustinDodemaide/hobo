extends StateMachine

@export var player:Player
@export var model:Node3D
var immobile:bool

func _physics_process(delta: float) -> void:
	state.physics_update(delta)
	
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	if not player.is_on_floor() and gravity:
		player.velocity.y -= gravity * delta

func immobilize():
	immobile = true
	transition("NotMoving")
