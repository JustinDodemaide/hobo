extends Node3D
class_name TrainCar

@onready var spawn_point = $Spawn
@export var cot:Node3D
@export var sheet:Node3D

var allow_player_exit = false

func open_door() -> void:
	allow_player_exit = true
	
	var tween = create_tween()
	var new_pos = Vector3(-2,2,-2)
	tween.tween_property($Door, "position", new_pos, 3.0).set_ease(Tween.EASE_OUT)
	
func close_door() -> void:
	var tween = create_tween()
	var new_pos = Vector3(2,2,2)
	tween.tween_property($Door, "position", new_pos, 3.0).set_ease(Tween.EASE_OUT)

var debounce_delay = []
func _on_area_3d_body_entered(body: Node3D) -> void:
	if debounce_delay.has(body):
		return
	debounce_delay.append(body)
	
	print(body.name + " entered")
	body.reparent(self)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if allow_player_exit == false:
		return
	
	if debounce_delay.has(body):
		return
	debounce_delay.append(body)
	
	print(body.name + " exited")
	if Global.level:
		body.reparent(Global.level)

func _on_debounce_timer_timeout() -> void:
	debounce_delay.clear()
