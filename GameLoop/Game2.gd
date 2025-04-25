extends Node
class_name Game

var car:TrainCar
var world:World
var map:WorldMap

var DEFAULT_RESOURCE_REDUCTION:int = 5
var MAX_RESOURCES:int = 20
var resources:Dictionary

var MAX_MORALE:int = 3
var morale:int = 3

var stage:Stage

func _ready() -> void:
	Global.game = self
	start_game()

func initialize_new_game():
	pass

func load_game_from_file():
	pass

func start_game():
	# Initialize the train car, players, and world
	var starting_item_amount = MAX_RESOURCES / 2
	for i in Item.RESOURCE_CATEGORIES.size():
		resources[i] = starting_item_amount
	
	SignalBus.item_deposited.connect(_item_deposited)
	
	var train_car = preload("res://Train/TrainCar/TrainCar.tscn").instantiate()
	add_child(train_car)
	car = train_car
	
	var player = preload("res://Player/Player.tscn").instantiate()
	train_car.add_child(player)
	player.global_position = train_car.spawn_point.global_position
	Global.players.append(player)
	
	world = load("res://World/World.gd").new()
	world.generate(5)
	
	stage_select()

func stage_select():
	map = world.generate_map()
	map.global_position = Vector3(-100,-100,-100)
	add_child(map)
	map.selection_made.connect(stage_selected)
	map.activate()

func stage_selected(icon:MapNodeIcon):
	stage = icon.stage
	map.queue_free()
	start_stage()

func start_stage():
	for stop in stage.stops:
		stop = stop.instantiate()
		add_child(stop)
		emit_signal("stage_started")
		await stop.complete
		stop.queue_free()
		SignalBus.emit_signal("stop_complete")
		
		for key in resources:
			var reduction = DEFAULT_RESOURCE_REDUCTION
			if stage.resource_deduction_modifiers.has(key):
				var multiplier = stage.resource_deduction_modifiers[key]
				reduction *= multiplier
			resources[key] -= reduction
			if resources[key] <= 0:
				resources[key] = 0
				morale -= 1
				if morale <= 0:
					print("Lose!")
					#get_tree().quit()
		SignalBus.emit_signal("resources_deducted")
	stage_select()

func _item_deposited(item:Item):
	resources[item.category()] += item.resource_value()
