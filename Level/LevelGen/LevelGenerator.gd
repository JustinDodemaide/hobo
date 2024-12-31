extends Node

const CARDINALS:Dictionary = {
	"N":Vector2i(0,-1),
	"S":Vector2i(0,1),
	"E":Vector2i(1,0),
	"W":Vector2i(-1,0),
	
	"NE":Vector2i(1,-1),
	"NW":Vector2i(-1,-1),
	"SE":Vector2i(1,1),
	"SW":Vector2i(-1,1)
}

const LEVEL_SIZE:int = 50 # assuming the level is always going to be a square which. Idk
const MAX_RECTANGLE_SIZE:int = 6
const DISTANCE_BETWEEN_RECTANGLES:int = 1
var tilemap = preload("res://Level/LevelGen/Debug/LevelGen_DebugTilemap.tscn").instantiate()

func run():
	Global.level.add_child(tilemap)
	for x in LEVEL_SIZE:
		for y in LEVEL_SIZE:
			tilemap.place(Vector2i(x,y), tilemap.road)
	# Place initial rectangle
	var middle = int(LEVEL_SIZE/2)
	var rectangle = await make_rectangle(Vector2i(middle,middle))
	# await $Button.pressed
	populate(rectangle)
	#for i in 5:
		#var tile = rectangle.pick_random()
		#var possible_rectangle_spaces = get_tiles_that_are_valid_for_new_rectangle_placement(tile)
		#rectangle = make_rectangle(possible_rectangle_spaces.pick_random())

func populate(rectangle):
	rectangle.shuffle()
	for tile in rectangle:
		var possible_rectangle_spaces = get_tiles_that_are_valid_for_new_rectangle_placement(tile)
		if possible_rectangle_spaces.is_empty():
			continue
		await $Button.pressed
		var new_rectangle = await make_rectangle(possible_rectangle_spaces.pick_random())
		populate(new_rectangle)
	
func make_rectangle(where:Vector2i) -> Array[Vector2i]:
	tilemap.place(where, tilemap.rectangle)
	return [where]
	
	# Makes the rectangle and also returns its tiles
	var sprite = Sprite2D.new()
	sprite.texture = load("res://dot2.png")
	add_sibling(sprite)
	
	# Figure out the bounds of the area we're working with
	var smallest_width:int = MAX_RECTANGLE_SIZE
	var smallest_length:int = MAX_RECTANGLE_SIZE
	# Goes down each column, left to right
	# AH HA
	# IT NEEDS TO GO UP
	# BECAUSE EACH OF THE VALID SPACES IS THE POTENTIAL *BOTTOM* LEFT OF A NEW RECTANGLE
	# wait no. depending on whether its above or below the current rectangle
	for x in range(MAX_RECTANGLE_SIZE):
		for y in range(MAX_RECTANGLE_SIZE):
			var current_tile := where - Vector2i(x,y)
			if the_tile_is_valid(current_tile):
				continue
			if x < smallest_width:
				smallest_width = x
			if y < smallest_length:
				smallest_length = y
	#Log.prn("Max rectangle size: ", Vector2i(smallest_width,smallest_length))
	# I'm undecided on whether every rectangle should be as large as possible,
	# or if the size should be random
	# var maximum_possible_dimensions := Vector2i(smallest_width,smallest_length)
	var rectangle:Array[Vector2i]
	for x in range(smallest_width):
		for y in range(smallest_length):
			var tile := Vector2i(x,y) + where
			rectangle.append(tile)
			tilemap.place(tile, tilemap.rectangle)
	#Log.prn("Rectangle: ", rectangle)
	return rectangle

func get_tiles_that_are_valid_for_new_rectangle_placement(center:Vector2i) -> Array[Vector2i]:
	var valid_tiles:Array[Vector2i] = []
	var visited:Array[Vector2i] = [center]
	
	# BFS queue: store (coords, distance)
	var queue := [{"tile":center,"distance":0}]
	while !queue.is_empty():
		# Log.prn(queue)
		var current = queue.pop_front()
		var tile = current.tile
		var distance = current.distance
		if distance > DISTANCE_BETWEEN_RECTANGLES and the_tile_is_valid(tile):
			valid_tiles.append(tile)
			continue
		for direction in CARDINALS:
			var neighbor = tile + CARDINALS[direction]
			if neighbor.x >= LEVEL_SIZE or neighbor.x < 0 or neighbor.y >= LEVEL_SIZE or neighbor.y < 0:
				continue
			if !the_tile_is_valid(neighbor):
				continue
			if visited.has(neighbor):
				continue
			visited.append(neighbor)
			queue.append({"tile":neighbor,"distance":distance + 1})
	
	tilemap.set_cell(center,0,tilemap.rectangle)
	#for i in valid_tiles:
	#	tilemap.set_cell(i,0,tilemap.possible)
	return valid_tiles

func the_tile_is_valid(tile:Vector2i) -> bool:
	# ● Vector2i get_cell_atlas_coords(coords: Vector2i) const
	# Returns the tile atlas coordinates ID of the cell at coordinates coords. Returns Vector2i(-1, -1) if the cell does not exist.
	if tilemap.get_cell_atlas_coords(tile) == tilemap.rectangle:
		return false
	return true
