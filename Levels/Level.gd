extends Node3D
class_name Level

@export var pullup_time:float = 30
@export var level_time:float = 1#00
@export var leave_time:float = 30

@export var ui:CanvasLayer
@export var timer:Timer
var car:TrainCar

signal complete

func _ready() -> void:
	Global.level = self
	var level_gen = $LevelGen
	level_gen.level = self
	level_gen.generate()
	
	car = Global.game.car
	car.global_position = $Tracks.start_marker.global_position
	_start()

func _start() -> void:
	var tween = create_tween()
	tween.finished.connect(_midpoint_reached)
	tween.tween_property(car,"position", $Tracks.middle_marker.global_position, pullup_time).set_trans(Tween.TRANS_CUBIC)

func _midpoint_reached() -> void:
	var tween = create_tween()
	tween.finished.connect(_end)
	tween.tween_interval(level_time)
	car.cot.interacted.connect(_end)

func _end() -> void:
	var tween = create_tween()
	tween.finished.connect(level_complete)
	tween.tween_property(car,"position", $Tracks.end_marker.global_position, leave_time).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	emit_signal("complete")
	queue_free()

func additional_ready_instructions() -> void:
	pass

func add_item(item:Item, where:Vector3, player:Player=null) -> void:
	var level_item = load("res://Item/LevelItem.tscn").instantiate()
	level_item.init(item)
	level_item.position = where
	add_child(level_item)
	level_item.dropped(player)

func level_complete() -> void:
	emit_signal("complete")

func _process(_delta: float) -> void:
	if $Timer.is_stopped():
		return
	$CanvasLayer/TextureProgressBar.value = 100 - $Timer.time_left
