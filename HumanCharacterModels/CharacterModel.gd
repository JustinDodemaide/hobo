extends Node3D

@export var animation_player:AnimationPlayer
enum ANIMATION{IDLE,WALK,JUMP}
var moving

func play_animation(animation:ANIMATION) -> void:
	match animation:
		ANIMATION.IDLE:animation_player.play("human/idle")
		ANIMATION.WALK:animation_player.play("human/walk")
		ANIMATION.JUMP:animation_player.play("human/jump")

func _process(delta: float) -> void:
	if moving:
		animation_player.speed_scale = $"../Movement".current_speed * 0.25
