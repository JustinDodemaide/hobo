extends Control

@export var category:Item.RESOURCE_CATEGORIES

func _ready() -> void:
	$VBoxContainer/Label.text = str(Item.RESOURCE_CATEGORIES.keys()[category])
	$VBoxContainer/ProgressBar.value = Global.game.resources[category]
	SignalBus.item_deposited.connect(item_deposited)
	SignalBus.resources_deducted.connect(update)

func item_deposited(item):
	if item.category() != category:
		return
	update()

func update():
	var tween = create_tween()
	tween.tween_property($VBoxContainer/ProgressBar,"value",Global.game.resources[category],2)
	#$VBoxContainer/ProgressBar.value = Global.game.resources[category]
