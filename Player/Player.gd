extends CharacterBody3D
class_name Player

@export var ui:Control

var SPEED = 50.0
var JUMP_VELOCITY = 7

const MAX_HEALTH:int = 100
var current_health:int = MAX_HEALTH

func _ready() -> void:
	Global.players.append(self)

var fast_mode:bool = true
func _physics_process(delta: float) -> void:
	#print(get_parent().name)
	
	if Input.is_action_pressed("Esc"):
		get_tree().quit()
	if Input.is_action_pressed("equal"):
		fast_mode = !fast_mode
		if fast_mode:
			SPEED = 50.0
			JUMP_VELOCITY = 7
		else:
			SPEED = 5.0
			JUMP_VELOCITY = 3
	handle_movement(delta)
	handle_inventory()
	$CanvasLayer/FPS.text = str(Engine.get_frames_per_second())

func handle_movement(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept"):# and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("A", "D", "W", "S")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

#region Inventory
var inventory = [null,null,null,null]
var inventory_index:int = 0
@export var item_cast:RayCast3D
@export var held_item_display:Sprite3D
var hovered_item:LevelItem
signal item_hovered
signal item_unhovered
signal inventory_updated
signal active_inventory_slot_changed(to:int)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("LeftClick"):
		if hovered_item:
			var item = hovered_item.item
			hovered_item.picked_up(self)
			hovered_item = null
			hold_item(item)
		return

	if event.is_action_pressed("F"):
		drop_item()
		return

	if event.is_action_pressed("1"):
		inventory_index = 0
	if event.is_action_pressed("2"):
		inventory_index = 1
	if event.is_action_pressed("3"):
		inventory_index = 2
	if event.is_action_pressed("4"):
		inventory_index = 3
	emit_signal("active_inventory_slot_changed",inventory_index)


func handle_inventory():
	var collider = item_cast.get_collider()
	if collider == null:
		if hovered_item:
			hovered_item = null
			emit_signal("item_unhovered")
		return
	hovered_item = collider
	emit_signal("item_hovered")

func hold_item(item:Item) -> void:
	drop_item()
	inventory[inventory_index] = item
	held_item_display.texture = load(item.image_path())
	emit_signal("inventory_updated")

func drop_item(index:int = -1):
	if index == -1:
		index = inventory_index
	if inventory[index] == null:
		return
	Global.level.add_item(inventory[index], global_position, self)
	inventory[index] = null
	held_item_display.texture = null
	emit_signal("inventory_updated")
#endregion
