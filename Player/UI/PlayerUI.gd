extends Control

var player:Player
@export var health:Control
@export var item_hover:VBoxContainer

func _ready() -> void:
	player = get_parent().get_parent()
	$MarginContainer/VBoxContainer/PlayerHealth.init(player)

func fade_in():
	return
	var final_color = Color(0,0,0,1.0)
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate", final_color, 8.0)

func fade_out(time:float = 10.0):
	var final_color = Color(0,0,0,1.0)
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate", final_color, time)

func _on_item_hovered() -> void:
	item_hover.get_node("HandIcon").visible = true
	
	var item = player.hovered_item.item
	var text:String = "E: Pickup " + item.item_name()
	#if item.is_consumable():
	#	text += "\nRightClick: Consume"
	item_hover.get_node("ItemPrompts").text = text

func _on_item_unhovered() -> void:
	item_hover.get_node("HandIcon").visible = false
	item_hover.get_node("ItemPrompts").text = ""

func _on_inventory_updated() -> void:
	var ui_slots = $MarginContainer/VBoxContainer/SlotContainer.get_children()
	for index in player.inventory.size():
		ui_slots[index].init(player.inventory[index])

var previously_active:int
func _on_player_active_inventory_slot_changed(to:int) -> void:
	var ui_slots = $MarginContainer/VBoxContainer/SlotContainer.get_children()
	ui_slots[previously_active].deactivate()
	ui_slots[to].activate()
	previously_active = to
	
	var label = $MarginContainer/VBoxContainer/ActiveItem
	if player.inventory[to]:
		label.text = player.inventory[to].item_name()
	else:
		label.text = ""
