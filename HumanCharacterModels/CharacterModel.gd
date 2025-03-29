extends Node3D

signal jumped
@export var animation_player:AnimationPlayer
var modifier:String


func play_animation(animation:String) -> void:
	match animation:
		"idle":animation_player.play("human/idle")
		"walk":animation_player.play("human/walk")
		"walk_backwards":animation_player.play_backwards("human/walk")
		"strafe_left":animation_player.play("human/strafe left")
		"strafe_right":animation_player.play("human/strafe right")
		"jump":animation_player.play("human/jump")


func jump():
	emit_signal("jumped")
