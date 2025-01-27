extends Node

var level:Level
var players:Array[Player]

func sprite(pos:Vector3) -> void:
	var sprite = Sprite3D.new()
	sprite.texture = load("res://icon.svg")
	sprite.position = pos
	level.add_child(sprite)

func item_from_string(item_name:String) -> Item:
	return load("res://Item/" + item_name + "/" + item_name + ".gd").new()
