extends Node3D
class_name TrainCar

func open_door() -> void:
	var tween = create_tween()
	var new_pos = Vector3(-2,2,-2)
	tween.tween_property($Door, "position", new_pos, 3.0).set_ease(Tween.EASE_OUT)
	
func close_door() -> void:
	var tween = create_tween()
	var new_pos = Vector3(2,2,2)
	tween.tween_property($Door, "position", new_pos, 3.0).set_ease(Tween.EASE_OUT)

func get_manifest():
	var players:Array[Player] = []
	var level_items:Array[LevelItem] = []
	var player_inventory_items:Array[Item] = []
	#for body in $Area3D.get_overlapping_bodies():
	for child in get_children():
		if child is Player:
			players.append(child)
			for item in child.inventory_component.inventory:
				if item != null:
					player_inventory_items.append(item)
		if child is LevelItem:
			level_items.append(child)
	var info = {
		"players":players,
		"level_items":level_items
	}
	print("\n")
	for i in get_children():
		print(i.name)
	return info

func all_items() -> Dictionary:
	var items = {}
	for child in get_children():
		if child is Player:
			for item in child.inventory_component.inventory:
				if item != null:
					if items.has(item):
						items[item] += 1
					else:
						items[item] = 1
		if child is LevelItem:
			if items.has(child.item):
				items[child.item] += 1
			else:
				items[child.item] = 1
	return items

var debounce_delay = []
func _on_area_3d_body_entered(body: Node3D) -> void:
	if debounce_delay.has(body):
		return
	debounce_delay.append(body)
	
	print(body.name + " entered")
	body.reparent(self)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if debounce_delay.has(body):
		return
	debounce_delay.append(body)
	
	print(body.name + " exited")
	if Global.level:
		body.reparent(Global.level)

func _on_debounce_timer_timeout() -> void:
	debounce_delay.clear()
