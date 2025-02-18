extends Node

var scene_handler:StateMachine
var level:Level
var players:Array[Player]

func sprite(pos:Vector3) -> void:
	var sprite = Sprite3D.new()
	sprite.texture = load("res://icon.svg")
	sprite.position = pos
	level.add_child(sprite)

func item_from_string(item_name:String) -> Item:
	return load("res://Item/" + item_name + "/" + item_name + ".gd").new()


class TrainCarInfo:
	class TrainCarItem:
		var item_name:String
		var position:Vector3
	
	class TrainCarPlayers:
		var position:Vector3
	
	var items:Array[TrainCarItem]
	var players:Array[TrainCarPlayers]

	func update(car):
		car.get_info()
