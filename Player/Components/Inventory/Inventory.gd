extends Node

@export var player:Player

var inventory:Array[Item] = [null,null,null,null]
var inventory_size:int = 4
var inventory_index:int = 0
@export var item_cast:RayCast3D
@export var held_item_display:Sprite3D
var hovered_item:LevelItem

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		if hovered_item:
			var item = hovered_item.item
			hovered_item.picked_up(player)
			hovered_item = null
			hold_item(item)
			player.ui.item_unhovered()
			return
	if event.is_action_pressed("F"):
		drop_item()
		return
	
	if event.is_action_pressed("LeftClick"):
		if inventory[inventory_index]:
			inventory[inventory_index].use(player)
	if event.is_action_pressed("RightClick"):
		if inventory[inventory_index]:
			inventory[inventory_index].use_alternate(player)
		return
	if event.is_action_pressed("1"):
		inventory_index = 0
	if event.is_action_pressed("2"):
		inventory_index = 1
	if event.is_action_pressed("3"):
		inventory_index = 2
	if event.is_action_pressed("4"):
		inventory_index = 3
	player.held_item = inventory[inventory_index]
	player.ui.active_inventory_slot_changed(inventory_index)

func _process(delta: float) -> void:
	var collider = item_cast.get_collider()
	if collider is LevelItem:
		hovered_item = collider
		player.ui.item_hovered()
	else:
		if hovered_item:
			hovered_item = null
			player.ui.item_unhovered()


func hold_item(item:Item) -> void:
	drop_item()
	inventory[inventory_index] = item
	held_item_display.texture = load(item.image_path())
	player.ui.inventory_updated()

func drop_item(index:int = -1) -> void:
	if index == -1:
		index = inventory_index
	if inventory[index] == null:
		return
	if Global.level:
		Global.level.add_item(inventory[index], player.global_position, player)
	inventory[index] = null
	held_item_display.texture = null
	player.ui.inventory_updated()

func remove_item(item:Item = null) -> void:
	if item:
		var index = inventory.find(item)
		if index != -1:
			inventory[index] = null
			return
	inventory[inventory_index] = null
