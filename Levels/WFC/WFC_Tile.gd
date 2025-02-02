# Tile class to represent different map elements
class_name Tile

var tile_name: String
var atlas:Vector2i
var options_for_direction: Dictionary = {}  # Direction: [allowed tile types]

func _init(_name: String, atlas_coords):
	tile_name = _name
	atlas = atlas_coords
	options_for_direction = {}
