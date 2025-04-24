extends Control

@export var category:Item.RESOURCE_CATEGORIES

func _ready() -> void:
	$VBoxContainer/Label.text = str(Item.RESOURCE_CATEGORIES.keys()[category])
	$VBoxContainer/ProgressBar.value = Global.resources[category]
	SignalBus.item_deposited.connect(update)
	SignalBus.resources_deducted.connect(update)

func update(item:Item):
	if item.category() != category:
		return
	var tween = create_tween()
	tween.tween_property($VBoxContainer/ProgressBar,"value",Global.resources[category],2)
	# $VBoxContainer/ProgressBar.value = Global.resources[category]
