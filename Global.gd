extends Node

var scene_handler:StateMachine
var level:Level
var players:Array[Player]

var sustenance_deduction:int = 4

enum DIRECTION{NORTH,NORTHEAST,EAST,SOUTHEAST,SOUTH,SOUTHWEST,WEST,NORTHWEST}

func sprite(pos:Vector3) -> void:
	var sprite = Sprite3D.new()
	sprite.texture = load("res://icon.svg")
	sprite.position = pos
	level.add_child(sprite)

func item_from_path(path:String) -> Item:
	return load(path).new()

func get_opposite_direction(from:DIRECTION) -> DIRECTION:
	match from:
		DIRECTION.NORTH:
			return DIRECTION.SOUTH
		DIRECTION.SOUTH:
			return DIRECTION.NORTH
		DIRECTION.EAST:
			return DIRECTION.WEST
		DIRECTION.WEST:
			return DIRECTION.EAST
		DIRECTION.NORTHEAST:
			return DIRECTION.SOUTHWEST
		DIRECTION.NORTHWEST:
			return DIRECTION.SOUTHEAST
		DIRECTION.SOUTHEAST:
			return DIRECTION.NORTHWEST
		DIRECTION.SOUTHWEST:
			return DIRECTION.NORTHEAST
	return DIRECTION.NORTH

func get_direction_normal(direction:DIRECTION):
	match direction:
		DIRECTION.NORTH:
			return Vector3(0, 0, -1)
		DIRECTION.NORTHEAST:
			return Vector3(1, 0, -1).normalized()
		DIRECTION.EAST:
			return Vector3(1, 0, 0)
		DIRECTION.SOUTHEAST:
			return Vector3(1, 0, 1).normalized()
		DIRECTION.SOUTH:
			return Vector3(0, 0, 1)
		DIRECTION.SOUTHWEST:
			return Vector3(-1, 0, 1).normalized()
		DIRECTION.WEST:
			return Vector3(-1, 0, 0)
		DIRECTION.NORTHWEST:
			return Vector3(-1, 0, -1).normalized()
		_:
			return Vector3.ZERO

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
