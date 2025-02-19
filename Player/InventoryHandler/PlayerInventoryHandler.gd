extends RayCast3D

@export var player:Player
@export var hand_icon:Sprite3D
@export var held_item:Sprite3D

var inventory = [null, null, null, null]
var inventory_index = 0

var hovered_item:LevelItem = null

const PICKUP_INPUT = "LeftClick"
const CONSUME_INPUT = "RightClick"

func _process(delta: float) -> void:
	handle_item_raycast()
	if Input.is_action_just_pressed(PICKUP_INPUT):
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
		held_item.texture = load(item.image_path())

func hold_item(item:Item) -> void:
	drop_item()
	inventory[inventory_index] = item
	held_item.texture = load(item.image_path())
	player.ui.inventory.update(inventory)

func drop_item(index:int = -1):
	var i = index
	if index == -1:
		i = inventory_index
	
	if inventory[i] == null:
		return
	
	Global.level.add_item(inventory[i], player.global_position, player)
	inventory[i] = null
	held_item.texture = null
	player.ui.inventory.update(inventory)

func handle_item_raycast() -> void:
	var collider = get_collider()
	if collider is LevelItem:
		hand_icon.visible = true
		hovered_item = collider
		# print("looking at ", collider.name)
	else:
		hovered_item = null
		hand_icon.visible = false
	player.ui.inventory.update_prompts(self)
