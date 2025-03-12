extends Control

@export var player:Player

@export_category("UI Elements")
@export var checkpoint_label:Label
@export var level_goal_label:Label
@export var health_scene:Control
@export var held_item_label:Label
@export var inventory_slots:HBoxContainer
@export var hand_icon:TextureRect
@export var item_prompt:Label
@export var interaction_prompt:Label

@export_category("Player Components")
@export var health_component:Node
@export var inventory_component:Node
@export var interaction_component:Node

func _ready() -> void:
	pass
	#$MarginContainer/VBoxContainer/PlayerHealth.init(player)

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
	hand_icon.visible = true
	var item = player.inventory_component.hovered_item.item
	var text:String = "E: Pickup " + item.item_name()
	item_prompt.text = text

func item_unhovered() -> void:
	hand_icon.visible = false
	item_prompt.text = ""

func inventory_updated() -> void:
	var ui_slots = inventory_slots.get_children()
	for index in player.inventory_component.inventory_size:
		ui_slots[index].init(player.inventory_component.inventory[index])

var previously_active:int
func active_inventory_slot_changed(to:int) -> void:
	var ui_slots = inventory_slots.get_children()
	ui_slots[previously_active].deactivate()
	ui_slots[to].activate()
	previously_active = to
	
	if player.inventory_component.inventory[to]:
		held_item_label.text = player.inventory_component.inventory[to].item_name()
	else:
		held_item_label.text = ""

func interactable_hovered() -> void:
	hand_icon.visible = true
	interaction_prompt.visible = true

func interactable_unhovered() -> void:
	hand_icon.visible = false
	interaction_prompt.visible = false

func between_stops() -> void:
	_update_checkpoint_text()

func _update_checkpoint_text() -> void:
	var text = Global.scene_handler.upcoming_checkpoint.description
	text += ": " + str(Global.scene_handler.distance_to_checkpoint) + " stops left"
	checkpoint_label.text = text
	
func _update_level_goal_text() -> void:
	pass
