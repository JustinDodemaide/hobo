extends Control

var player:Player
@export var health:Control
@export var inventory:Control

func _ready() -> void:
	player = get_parent().get_parent()
	$MarginContainer/VBoxContainer/PlayerHealth.init(player)
	$MarginContainer/VBoxContainer/PlayerHealth.set_size(inventory.size)
