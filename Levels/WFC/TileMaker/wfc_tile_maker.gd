extends PanelContainer

		#tiles = [
			#Tile.new("deep_water",Vector2i(46,0)),
			#Tile.new("shallow_water",Vector2i(47,0)),
			#Tile.new("beach",Vector2i(63,0)),
			#Tile.new("grass",Vector2i(30,0)),
			##Tile.new("building",Vector2i(6,0)),
			##Tile.new("dock")
		#]
		#
		## Deep water can only have deep water to its "ocean side" (north in this case)
		#tiles[0].options_for_direction = {
			#"north": ["deep_water"],  # Ocean direction
			#"south": ["deep_water", "shallow_water"],  # Towards shore
			#"east": ["deep_water"],  # Keep ocean connected
			#"west": ["deep_water"]   # Keep ocean connected
		#}

@export var items:VBoxContainer
func _on_new_item_pressed() -> void:
	var item = load("res://Level/LevelGen/WFC/TileMaker/WFCTileMakerItem.tscn").instantiate()
	items.add_child(item)
	item.init(items.get_children())
	item.item_name_changed.connect(item_name_changed)

func item_name_changed(from,to):
	for item in items.get_children():
		item.update(from,to)

func _on_confirm_pressed() -> void:
	var tiles = []
	for item in items.get_children():
		var tile_name = item.item_name
		var atlas_coords = Vector2i(item.atlas_x, 0)
		var new_tile = Tile.new(tile_name,atlas_coords)
		new_tile.options_for_direction = item.get_directions()
		tiles.append(new_tile)
		
		var tileset_name = $MarginContainer/ScrollContainer/VBoxContainer/Name.text
		var file = FileAccess.open("res://Level/LevelGen/WFC/Tiles/" + tileset_name + ".txt", FileAccess.WRITE)
		file.flush()
		file.store_string(var_to_str(tiles))
		file.close()
		get_tree().quit()
