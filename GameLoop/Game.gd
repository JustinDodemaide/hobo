extends Node

var train_car:TrainCar
var world:World
var stage:Stage

const STARTING_ITEM_AMOUNT = 10

func _ready() -> void:
	var starting_item_amount = Global.MAX_RESOURCES / 2
	for i in Item.RESOURCE_CATEGORIES.size():
		Global.resources[i] = starting_item_amount
	SignalBus.item_deposited.connect(item_deposited)
	initialize_new_game()

func initialize_new_game() -> void:
	train_car = load("res://Train/TrainCar/TrainCar.tscn").instantiate()
	add_child(train_car)
	Global.car = train_car
	
	var player = load("res://Player/Player.tscn").instantiate()
	train_car.add_child(player)
	player.global_position = train_car.spawn_point.global_position
	Global.players.append(player)
	
	world = load("res://World/World.gd").new()
	world.generate(5)
	
	add_child(load("res://GameLoop/StageSelect.tscn").instantiate())

func item_deposited(item:Item):
	print(Global.resources)
	print(item.category())
	Global.resources[item.category()] += item.resource_value()
