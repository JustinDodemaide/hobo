extends Node3D
class_name Level

@export var path:Path3D
var car:TrainCar

func _ready() -> void:
	Global.level = self
	var level_gen = $LevelGen
	level_gen.level = self
	level_gen.generate()
	
#	var train = load("res://Train/Train.tscn").instantiate()
#	$Tracks.add_child(train)
#	car = train.get_node("TrainCar")
	
	#var player = load("res://Player/Player.tscn").instantiate()
	#Global.players.append(player)
	#var timer = get_tree().create_timer(0.1)
	#await timer.timeout
	#player.global_position = train.spawn_point.global_position
	
	$Tracks.start()

func additional_ready_instructions() -> void:
	pass

func add_item(item:Item, where:Vector3, player:Player=null) -> void:
	var level_item = load("res://Item/LevelItem.tscn").instantiate()
	level_item.init(item)
	level_item.position = where
	add_child(level_item)
	level_item.dropped(player)

func level_complete() -> void:
	pass
