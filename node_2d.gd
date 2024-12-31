extends Node2D

var grid_size = Vector2(50, 50)  # Grid dimensions
const GRID_SIZE:int = 50
var walkable_tiles = []  # List of walkable tiles

func _ready() -> void:
	# dont remember what this was for but im hijacking it for level gen debugging
	Global.level = self
	var level_gen = load("res://Level/LevelGen/LevelGenerator.gd").new()
	level_gen.run()
	
	return
	generate_grid()

func generate_grid():
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.set_frequency(0.05)
	randomize()
	noise.seed = randi()
		
	var atlas_coords:Vector2i = Vector2i(37,0)
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var coords:Vector2i = Vector2i(x,y)
			var value = noise.get_noise_2dv(coords)
			if value > 0.3:
				# set_cell(coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0)
				$Floor.set_cell(coords, 0, atlas_coords)  # Set floor tile
				# walkable_tiles.append(Vector2(x, y))
			#else:
			#	$Walls.set_cell(x, y, 1)  # Set wall tile

func get_walkable_tiles() -> Array:
	return walkable_tiles
