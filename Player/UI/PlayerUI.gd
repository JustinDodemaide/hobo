extends Control

var player:Player
@export var health:Control
@export var inventory:Control

func _ready() -> void:
	player = get_parent().get_parent()
	$MarginContainer/VBoxContainer/PlayerHealth.init(player)
	$MarginContainer/VBoxContainer/PlayerHealth.set_size(inventory.size)

func fade_in():
	return
	var final_color = Color(0,0,0,1.0)
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate", final_color, 8.0)

func fade_out(time:float = 10.0):
	var final_color = Color(0,0,0,1.0)
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate", final_color, time)
