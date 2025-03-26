extends Node3D

@export var tilemap:TileMapLayer

@export var maze_width := 31  # Must be odd
@export var maze_height := 31
@export var wall_tile := Vector2i(0, 0)
@export var floor_tiles := {
	"vertical": Vector2i(1, 0),
	"horizontal": Vector2i(2, 0),
	"corner_ne": Vector2i(3, 0),
	"corner_es": Vector2i(4, 0),
	"corner_sw": Vector2i(5, 0),
	"corner_wn": Vector2i(6, 0),
	"t_junction_n": Vector2i(7, 0),
	"t_junction_e": Vector2i(8, 0),
	"t_junction_s": Vector2i(9, 0),
	"t_junction_w": Vector2i(10, 0),
	"cross": Vector2i(11, 0),
	"dead_end_n": Vector2i(12, 0),
	"dead_end_e": Vector2i(13, 0),
	"dead_end_s": Vector2i(14, 0),
	"dead_end_w": Vector2i(15, 0)
}
var meshes = {
	"vertical": [load("res://Levels/GridTown/Sewer/Meshes/Scenes/Vertical.tscn"),
				load("res://Levels/GridTown/Sewer/Meshes/Scenes/Vertical_Room.tscn")],
	"horizontal": [load("res://Levels/GridTown/Sewer/Meshes/Scenes/Vertical.tscn")],
	"corner_ne": [load("res://Levels/GridTown/Sewer/Meshes/Scenes/Corner.tscn")],
	"corner_es": [load("res://Levels/GridTown/Sewer/Meshes/Scenes/Corner.tscn")],
	"corner_sw": [load("res://Levels/GridTown/Sewer/Meshes/Scenes/Corner.tscn")],
	"corner_wn": [load("res://Levels/GridTown/Sewer/Meshes/Scenes/Corner.tscn")],
	"t_junction_n": [load("res://Levels/GridTown/Sewer/Meshes/Scenes/Junction.tscn")],
	"t_junction_e": [load("res://Levels/GridTown/Sewer/Meshes/Scenes/Junction.tscn")],
	"t_junction_s": [load("res://Levels/GridTown/Sewer/Meshes/Scenes/Junction.tscn")],
	"t_junction_w": [load("res://Levels/GridTown/Sewer/Meshes/Scenes/Junction.tscn")],
	"cross": [load("res://Levels/GridTown/Sewer/Meshes/Scenes/Cross.tscn")],
	"dead_end_n": [load("res://Levels/GridTown/Sewer/Meshes/Scenes/DeadEnd.tscn")],
	"dead_end_e": [load("res://Levels/GridTown/Sewer/Meshes/Scenes/DeadEnd.tscn")],
	"dead_end_s": [load("res://Levels/GridTown/Sewer/Meshes/Scenes/DeadEnd.tscn")],
	"dead_end_w": [load("res://Levels/GridTown/Sewer/Meshes/Scenes/DeadEnd.tscn")]
}

var player

func _ready() -> void:
	generate_maze()
	identify_tunnel_types()
	place_3d_meshes()
	
	player = load("res://Player/Player.tscn").instantiate()
	add_child(player)
	player.global_position = get_children().pick_random().spawn.global_position

func generate_maze() -> void:
	for x in maze_width:
		for y in maze_height:
			tilemap.set_cell(Vector2i(x, y), 0, wall_tile)
	
	var stack: Array[Vector2i] = []
	var start_pos := Vector2i(1, 1)
	tilemap.set_cell(start_pos, 0, floor_tiles["vertical"])
	stack.push_back(start_pos)
	
	var directions := [
		Vector2i(0, -2), Vector2i(2, 0),
		Vector2i(0, 2), Vector2i(-2, 0)
	]
	
	while not stack.is_empty():
		var current = stack.pop_back()
		directions.shuffle()
		var found := false
		
		for dir in directions:
			var next = current + dir
			if next.x < 1 or next.x >= maze_width - 1:
				continue
			if next.y < 1 or next.y >= maze_height - 1:
				continue
			
			if tilemap.get_cell_atlas_coords(next) == wall_tile:
				var between = current + (dir / 2)
				tilemap.set_cell(between, 0, floor_tiles["vertical"])
				tilemap.set_cell(next, 0, floor_tiles["vertical"])
				stack.push_back(current)
				stack.push_back(next)
				found = true
				break
		
		if not found and not stack.is_empty():
			stack.push_back(stack.pop_back())

func identify_tunnel_types() -> void:
	for x in maze_width:
		for y in maze_height:
			var pos := Vector2i(x, y)
			if tilemap.get_cell_atlas_coords(pos) == wall_tile:
				continue
			
			var connections := get_connections(pos)
			tilemap.set_cell(pos, 0, determine_tile_type(connections))

func get_connections(pos: Vector2i) -> Dictionary:
	# Standard 2D tilemap grid:
	# +Y is down (south)
	# -Y is up (north)
	# +X is right (east)
	# -X is left (west)
	return {
		north = is_floor(pos + Vector2i(0, -1)),
		east = is_floor(pos + Vector2i(1, 0)),
		south = is_floor(pos + Vector2i(0, 1)),
		west = is_floor(pos + Vector2i(-1, 0))
	}

func is_floor(pos: Vector2i) -> bool:
	return tilemap.get_cell_atlas_coords(pos) != wall_tile

# This function remains the same, since tile typing logic is consistent
func determine_tile_type(conn: Dictionary) -> Vector2i:
	var count := int(conn.north) + int(conn.east) + int(conn.south) + int(conn.west)
	
	match count:
		1: # Dead end
			if conn.north: return floor_tiles["dead_end_n"]
			if conn.east: return floor_tiles["dead_end_e"]
			if conn.south: return floor_tiles["dead_end_s"]
			return floor_tiles["dead_end_w"]
		
		2: # Straight or corner
			if conn.north && conn.south: return floor_tiles["vertical"]
			if conn.east && conn.west: return floor_tiles["horizontal"]
			if conn.north && conn.east: return floor_tiles["corner_ne"]
			if conn.east && conn.south: return floor_tiles["corner_es"]
			if conn.south && conn.west: return floor_tiles["corner_sw"]
			return floor_tiles["corner_wn"]
		
		3: # T-junction
			if !conn.north: return floor_tiles["t_junction_n"]
			if !conn.east: return floor_tiles["t_junction_e"]
			if !conn.south: return floor_tiles["t_junction_s"]
			return floor_tiles["t_junction_w"]
		
		4: # Cross
			return floor_tiles["cross"]
	
	return wall_tile

# New function to place 3D meshes
func place_3d_meshes() -> void:
	# Create a reverse mapping from tile coords to type strings
	var coords_to_type = {}
	for type_name in floor_tiles:
		coords_to_type[floor_tiles[type_name]] = type_name
	
	# Place 3D meshes for each floor tile
	for x in maze_width:
		for y in maze_height:
			var pos := Vector2i(x, y)
			var atlas_coords = tilemap.get_cell_atlas_coords(pos)
			
			# Skip walls
			if atlas_coords == wall_tile:
				continue
				
			# Get the tile type string
			if not coords_to_type.has(atlas_coords):
				continue
				
			var tile_type = coords_to_type[atlas_coords]
			
			# Skip if we don't have a mesh for this type
			if not meshes.has(tile_type):
				continue
			
			# Instantiate the mesh
			var mesh_scene = meshes[tile_type].pick_random()
			var mesh_instance = mesh_scene.instantiate()
			
			# Position the mesh in 3D space
			# When converting from 2D to 3D:
			# 2D X → 3D X (east-west)
			# 2D Y → 3D Z (north-south), where positive Z is north
			mesh_instance.position = Vector3(x, 0, y) * 12
			
			# Call the orient function on the mesh, passing the tile type string
			# In this system, a "t_junction_n" has an opening to the north (positive Z)
			
			# Call the orient function on the mesh, passing the tile type string
			mesh_instance.orient(tile_type)
			
			# Add the mesh to our scene
			add_child(mesh_instance)
	
	# Add water plane
	var water = load("res://Shaders/WaterPlane.tscn").instantiate()
	add_child(water)
