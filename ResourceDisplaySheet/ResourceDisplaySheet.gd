extends Node3D

func _ready() -> void:
	SignalBus.resources_deducted.connect(update_morale)
	$Sprite3D/SubViewport/VBoxContainer/Label.text = "Morale: " + str(Global.game.MAX_MORALE)

func update_morale():
	$Sprite3D/SubViewport/VBoxContainer/Label.text = "Morale: " + str(Global.game.morale)
