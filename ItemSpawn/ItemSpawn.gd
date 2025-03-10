extends Marker3D

@export var item_name:String

var item_paths = [
	"res://Item/ResourceCategories/a/Bread/Bread.gd",
	"res://Item/ResourceCategories/b/1/b1.gd",
	"res://Item/ResourceCategories/c/1/c1.gd",
	"res://Item/ResourceCategories/d/1/d1.gd",
	"res://Item/ResourceCategories/e/1/e1.gd"
]

func _ready() -> void:
	var item = Global.item_from_path(item_paths.pick_random())
	var level_item = load("res://Item/LevelItem.tscn").instantiate()
	Global.level.add_child(level_item)
	level_item.global_transform = global_transform
	level_item.init(item)
