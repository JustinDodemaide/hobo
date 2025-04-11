extends Node

var nodes
const MAX_CITIZENS:int = 1
var active_citizens:int = 0

func _init() -> void:
	nodes = Global.level.citizen_nodes
	for i in MAX_CITIZENS:
		make_citizen()

func make_citizen():
	var start = Global.level.citizen_nodes.pick_random()
	var end = Global.level.citizen_nodes.pick_random()
	if not start or not end:
		return
	var citizen = load("res://NPCs/Citizen/Citizen.tscn").instantiate()
	citizen.destination_reached.connect(destination_reached)
	citizen.global_position = start.global_position
	Global.level.add_child(citizen)
	citizen.go_to(end)
	active_citizens += 1

func destination_reached():
	active_citizens -= 1

func _on_timer_timeout() -> void:
	if active_citizens < MAX_CITIZENS:
		make_citizen()
	$Timer.start(5)
