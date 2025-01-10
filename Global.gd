extends Node

var level:Level
var players:Array[Player]

func sprite(pos:Vector3) -> void:
	var sprite = Sprite3D.new()
	sprite.texture = load("res://icon.svg")
	sprite.position = pos
	level.add_child(sprite)
