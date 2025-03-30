extends Node3D

signal jumped
@export var animation_player:AnimationPlayer
var modifier:String

var skeleton
var head_bone_idx = 9
@export var look_target:Node3D
func _ready() -> void:
	skeleton = $Armature/Skeleton3D
	#skeleton.set_bone_enabled(9, false)
	#print(skeleton.is_bone_enabled(9))
	pass


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

func ragdoll():
	$Armature/Skeleton3D.physical_bones_start_simulation()

func _physics_process(delta: float) -> void:
	$Armature/Skeleton3D/BoneAttachment3D/Head.look_at($"../Camera3D".global_position)
	$Armature/Skeleton3D/BoneAttachment3D/Head.rotate_object_local(Vector3(0, 1, 0), PI/2) # dont really understand this but it works
