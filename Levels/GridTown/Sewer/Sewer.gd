extends TileMapLayer

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

func _ready() -> void:
	generate_maze()
	identify_tunnel_types()

func generate_maze() -> void:
	for x in maze_width:
		for y in maze_height:
			set_cell(Vector2i(x, y), 0, wall_tile)
	
	var stack: Array[Vector2i] = []
	var start_pos := Vector2i(1, 1)
	set_cell(start_pos, 0, floor_tiles["vertical"])
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
			
			if get_cell_atlas_coords(next) == wall_tile:
				var between = current + (dir / 2)
				set_cell(between, 0, floor_tiles["vertical"])
				set_cell(next, 0, floor_tiles["vertical"])
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
			if get_cell_atlas_coords(pos) == wall_tile:
				continue
			
			var connections := get_connections(pos)
			set_cell(pos, 0, determine_tile_type(connections))

func get_connections(pos: Vector2i) -> Dictionary:
	return {
		north = is_floor(pos + Vector2i(0, -1)),
		east = is_floor(pos + Vector2i(1, 0)),
		south = is_floor(pos + Vector2i(0, 1)),
		west = is_floor(pos + Vector2i(-1, 0))
	}

func is_floor(pos: Vector2i) -> bool:
	return get_cell_atlas_coords(pos) != wall_tile

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
