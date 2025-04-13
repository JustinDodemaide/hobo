extends Node

var train_car:TrainCar
var world:World
var stage:Stage

func _ready() -> void:
	initialize_new_game()

func initialize_new_game() -> void:
	train_car = load("res://Train/TrainCar/TrainCar.tscn").instantiate()
	add_child(train_car)
	
	var player = load("res://Player/Player.tscn").instantiate()
	train_car.add_child(player)
	player.global_position = train_car.spawn_point.global_position
	Global.players.append(player)
	
	world = load("res://World/World.gd").new()
	world.generate(5)
	
	add_child(load("res://GameLoop/StageSelect.tscn").instantiate())
