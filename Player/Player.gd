extends CharacterBody3D
class_name Player

@export var ui:Control

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

#region Movement
var SPEED = 50.0
var JUMP_VELOCITY = 7
func handle_movement(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("ui_accept"):# and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Calculate effect of player input
	var input_dir := Input.get_vector("A", "D", "W", "S")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Determine how much control the player has (less when under external force)
	var control_factor = 1.0
	if external_velocity.length() > 0.01:
		control_factor = control_reduction
	
	if direction:
		velocity.x = direction.x * SPEED * control_factor
		velocity.z = direction.z * SPEED * control_factor
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * control_factor)
		velocity.z = move_toward(velocity.z, 0, SPEED * control_factor)
#endregion

#region Apply Force
	if external_velocity != Vector3.ZERO:
		velocity += external_velocity
		
		# Decay external forces
		external_velocity *= force_decay
		if external_velocity.length() < 0.01:
			external_velocity = Vector3.ZERO
	
	move_and_slide()

var external_velocity = Vector3.ZERO
var force_decay = 0.9  # How quickly forces diminish each frame
var control_reduction = 0.3  # Player retains 30% control when under external force
func apply_force(force_vector):
	external_velocity += force_vector

func apply_force_from_position(source_position, force_strength):
	var direction = global_position - source_position
	direction.y = clamp(direction.y, -0.5, 1.0)
	
	apply_force(direction.normalized() * force_strength)
#endregion

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
	if event.is_action_pressed("E"):
		if hovered_item:
			var item = hovered_item.item
			hovered_item.picked_up(self)
			hovered_item = null
			hold_item(item)
		return
	if event.is_action_pressed("F"):
		drop_item()
		return
	
	if event.is_action_pressed("LeftClick"):
		if inventory[inventory_index]:
			inventory[inventory_index].use(self)
	if event.is_action_pressed("RightClick"):
		if inventory[inventory_index]:
			inventory[inventory_index].use_alternate(self)
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
	if collider is not LevelItem:
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

func drop_item(index:int = -1) -> void:
	if index == -1:
		index = inventory_index
	if inventory[index] == null:
		return
	if Global.level:
		Global.level.add_item(inventory[index], global_position, self)
	inventory[index] = null
	held_item_display.texture = null
	emit_signal("inventory_updated")

func remove_item(item:Item = null) -> void:
	if item:
		var index = inventory.find(item)
		if index != -1:
			inventory[index] = null
			return
	inventory[inventory_index] = null
#endregion

func _on_timer_timeout() -> void:
	apply_force_from_position(global_position + Vector3(0,-10,0), 2)
