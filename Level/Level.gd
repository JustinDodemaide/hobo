extends Node3D
class_name Level

@export var path:Path3D
var car

func _ready() -> void:
	Global.level = self
	var level_gen = $LevelGen
	level_gen.level = self
	level_gen.generate()
	
	var train = load("res://Train/Train.tscn").instantiate()
	$Tracks.add_child(train)
	car = train.get_node("Car")
	
	var player = load("res://Player/Player.tscn").instantiate()
	player.name = "Player"
	var timer = get_tree().create_timer(0.1)
	await timer.timeout
	add_child(player)
	player.global_position = train.spawn_point.global_position
	# train.add_players(self)

func add_item(item:Item, where:Vector3, player:Player=null) -> void:
	var level_item = load("res://Item/LevelItem.tscn").instantiate()
	level_item.init(item)
	level_item.position = where
	add_child(level_item)
	level_item.dropped(player)
