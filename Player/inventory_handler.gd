extends Node

var player:Player

var inventory = [null, null, null, null]
var inventory_index = 0

var hovered_item:LevelItem = null

func _ready() -> void:
	# $"../Camera3D/ItemRaycast".add_exception($"../Camera3D/ItemRaycast")
	player = get_parent()

func _process(delta: float) -> void:
	handle_item_raycast()
	if Input.is_action_just_pressed("LeftClick"):
		if hovered_item:
			var item = hovered_item.item
			hovered_item.picked_up(player)
			hovered_item = null
			hold_item(item)
	
	if Input.is_action_pressed("F"):
		drop_item()

func scroll(right:bool) -> void:
	if right:
		inventory_index += 1
	else:
		inventory_index -= 1
	var item = inventory[inventory_index]
	if item:
		$"../Camera3D/HeldItem".texture = load(item.image_path())

func hold_item(item:Item) -> void:
	drop_item()
	inventory[inventory_index] = item
	$"../Camera3D/HeldItem".texture = load(item.image_path())
	update_ui()

func drop_item(index:int = -1):
	var i = index
	if index == -1:
		i = inventory_index
	
	if inventory[i] == null:
		return
	
	Global.level.add_item(inventory[i], player.position, player)
	inventory[i] = null
	$"../Camera3D/HeldItem".texture = null
	update_ui()

func handle_item_raycast() -> void:
	var collider = $"../Camera3D/ItemRayCast".get_collider()
	if collider:
		# print(collider.name)
		collider = collider.get_parent()
	if collider is LevelItem:
		$"../Camera3D/HandIcon".visible = true
		hovered_item = collider
		# print("looking at ", collider.name)
		return
	hovered_item = null
	$"../Camera3D/HandIcon".visible = false

func update_ui() -> void:
	player.ui.inventory.update(inventory)
