extends PanelContainer

@export var name_edit:TextEdit
var item_name = ""
signal item_name_changed(from,to)

var atlas_x = 0

func init(items):
	$VBoxContainer/Label.text += str(items.size())
	$VBoxContainer/Directions/north.init(items)
	$VBoxContainer/Directions/south.init(items)
	$VBoxContainer/Directions/east.init(items)
	$VBoxContainer/Directions/west.init(items)


func update(from,to):
	$VBoxContainer/Directions/north.update_options(from,to)
	$VBoxContainer/Directions/south.update_options(from,to)
	$VBoxContainer/Directions/east.update_options(from,to)
	$VBoxContainer/Directions/west.update_options(from,to)

func _on_atlas_text_changed() -> void:
	$VBoxContainer/Atlas.text = str($VBoxContainer/Atlas.text.to_int())
	atlas_x = $VBoxContainer/Atlas.text.to_int()

func _on_name_text_changed() -> void:
	if item_name == name_edit.text:
		return
	emit_signal("item_name_changed",item_name,name_edit.text)
	item_name = name_edit.text
	
func get_directions():
	var directions = {}
	for direction in $VBoxContainer/Directions.get_children():
		directions[direction.name] = direction.get_options()
	return directions
