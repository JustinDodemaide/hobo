extends Control

@export var player:Player
@export var health_ui:Control
@export var item_hover:VBoxContainer

@export_category("Player Components")
@export var health:Node
@export var inventory:Node
@export var interacting:Node

func _ready() -> void:
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

func item_hovered() -> void:
	item_hover.get_node("HandIcon").visible = true
	var item = player.inventory_component.hovered_item.item
	var text:String = "E: Pickup " + item.item_name()
	item_hover.get_node("ItemPrompts").text = text

func item_unhovered() -> void:
	item_hover.get_node("HandIcon").visible = false
	item_hover.get_node("ItemPrompts").text = ""

func inventory_updated() -> void:
	var ui_slots = $MarginContainer/VBoxContainer/SlotContainer.get_children()
	for index in player.inventory_component.inventory_size:
		ui_slots[index].init(player.inventory_component.inventory[index])

var previously_active:int
func active_inventory_slot_changed(to:int) -> void:
	var ui_slots = $MarginContainer/VBoxContainer/SlotContainer.get_children()
	ui_slots[previously_active].deactivate()
	ui_slots[to].activate()
	previously_active = to
	
	var label = $MarginContainer/VBoxContainer/ActiveItem
	if player.inventory_component.inventory[to]:
		label.text = player.inventory_component.inventory[to].item_name()
	else:
		label.text = ""

func interactable_hovered() -> void:
	$MarginContainer/ItemHover/HandIcon.visible = true
	$MarginContainer/ItemHover/InteractablePrompts.visible = true

func interactable_unhovered() -> void:
	$MarginContainer/ItemHover/HandIcon.visible = false
	$MarginContainer/ItemHover/InteractablePrompts.visible = false
