extends RigidBody3D
class_name LevelItem

@export var item_name:String
var item:Item = null
@onready var sprite:Sprite3D = $Sprite3D

func _ready() -> void:
	if not item_name.is_empty():
		init_from_name(item_name)

func init_from_name(item_name:String) -> void:
	init(load("res://Item/" + item_name + "/" + item_name + ".gd").new())

func init(item:Item) -> void:
	self.item = item
	$Sprite3D.texture = load(item.image_path())

func image_path() -> String:
	return item.image_path()

func picked_up(by:Player) -> void:
	item.picked_up(by)
	queue_free()

func dropped(by:Player) -> void:
	# var car = Global.level.car
	print(Global.level.car)
	var deposit = Global.level.car.get_node("Deposit")
	$DepositCheck.force_raycast_update()
	Log.prn($DepositCheck.get_collider())
	var area = $DepositCheck.get_collider()
	if area == deposit:
		#print(get_parent().name)
		global_position.y = deposit.global_position.y - 0.75
		freeze = true
		$MovingObjectHandler.enabled = false
		reparent(Global.level.car)
	item.dropped(by)
