extends Marker3D

@export var item_name:String

func _ready() -> void:
	var item = Global.item_from_string(item_name)
	var level_item = load("res://Item/LevelItem.tscn").instantiate()
	Global.level.add_child(level_item)
	print(global_position)
	level_item.global_transform = global_transform
	level_item.init(item)
