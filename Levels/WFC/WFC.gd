extends TileMapLayer

# Example usage in a Godot scene
func _ready():
	#test()
	#return

	var generator = WFCGenerator.new(20, 20)
	generator.generate("road")

	for x in generator.width:
		for y in generator.height:
			set_cell(Vector2i(y,x),0,generator.grid[y][x].atlas)

	
	generator.print_grid()
	
func make_rectangle(bottom_left_tile:Vector2i):
	pass

func test():
	const DIRECTIONS = [Vector2i(0, -1),Vector2i(0, 1),Vector2i(1,0),Vector2i(-1,0)]
	var num_placed = 0
	var max = 10
	var current = Vector2i(5,5)
	set_cell(current,0,Vector2i(0,0))
	while num_placed < max:
		for direction in DIRECTIONS:
			var potential = current + direction
			var adjacent = 0
			var good = true
			for directions2 in DIRECTIONS:
				var potentials_neighbor = potential + directions2
				if get_cell_tile_data(potentials_neighbor) != null:
					adjacent += 1
					if adjacent > 1:
						good = false
						break
			if not good:
				continue
			set_cell(potential,0,Vector2i(0,0))
			num_placed += 1
			current = potential
	
class TileConstraints:
	var min_count: int
	var max_count: int
	var current_count: int = 0
	
	func _init(p_min: int, p_max: int):
		min_count = p_min
		max_count = p_max

# Wave Function Collapse Generator
class WFCGenerator:
	var width: int
	var height: int
	var tiles: Array
	var grid:Array = []
	var entropy_grid:Array = []
	var constraints:Dictionary
	
	func _init(_width: int, _height: int):
		width = _width
		height = _height
		
		# Initialize empty grid
		for y in range(height):
			var row:Array[Tile] = []
			grid.append(row)
			entropy_grid.append([])
			for x in range(width):
				grid[y].append(null)
				entropy_grid[y].append([])
		# Superposition is the set of all the possible tiles
		# Entropy grid is a grid of superpositions
		# Grid is the actual grid of tiles, the ones selected by collapse

	# Generate the map
	func generate(config_name:String):
		#setup_coastal_biome()
		#get_tiles_from_file(file_name)
		var configs = load("res://Level/LevelGen/WFC/WFC_TileConfigs.gd").new()
		tiles = configs.get_tiles(config_name)
		initialize_entropy()
		
		while true:
			# Get the cell with the least possibities. If there aren't any
			# cells with possbilities, you're done
			var cell = get_lowest_entropy_cell()
			if cell == null:
				break
			
			collapse_cell(cell)
	
	#func get_tiles_from_file(file_name:String):
		#var new_file = FileAccess.open("res://Level/LevelGen/WFC/Tiles/" + file_name + ".txt", FileAccess.READ)
		#tiles = str_to_var(new_file.get_as_text())
	
	# Initialize possible tiles for each cell
	func initialize_entropy():
		for y in height:
			for x in width:
				entropy_grid[y][x] = tiles.duplicate()
	
	# Find cell with lowest entropy (least possibilities)
	func get_lowest_entropy_cell():
		var lowest_entropy_cells = []
		var lowest_entropy = tiles.size()
		
		for y in height:
			for x in width:
				# If this tile has already been decided, skip obviously
				if grid[y][x] != null:
					continue
				# The entropy is the number of possible options
				var current_entropy = entropy_grid[y][x].size()
				# We're trying to get all the cells that have the same (lowest)
				# entropy so we can pick a random one to collapse.
				if current_entropy > lowest_entropy:
					continue
				# So if we find a new lowest entropy, we gotta get all the ones
				#  with THAT entropy, which is why we clear the array
				if current_entropy < lowest_entropy:
					lowest_entropy = current_entropy
					# lowest_entropy_cells = [[x, y]]
					lowest_entropy_cells.clear()
					lowest_entropy_cells.append(Vector2i(x,y))
					continue
				if current_entropy == lowest_entropy: # unnecessary but nicer to read imo
					lowest_entropy_cells.append(Vector2i(x,y))
		if lowest_entropy_cells.is_empty():
			return null
		return lowest_entropy_cells.pick_random()

	func can_place_tile(tile_type: String) -> bool:
		if constraints.has(tile_type):
			return constraints[tile_type].current_count < constraints[tile_type].max_count
		return true
	
	# Collapse a cell by selecting a tile
	func collapse_cell(cell:Vector2i):
		var x = cell.x
		var y = cell.y
		# The entropy is all the possible options, so just look at the entropy
		# for this tile to get those options
		var possible_tiles = entropy_grid[y][x]
		# Choose an option at random
		var selected_tile = possible_tiles.pick_random()

		if not can_place_tile(selected_tile.tile_name):
			constraints[selected_tile.tile_name].current_count += 1
		if selected_tile == null:
			pass
		
		grid[y][x] = selected_tile
		entropy_grid[y][x] = [selected_tile]
		# ^This doesnt really make sense to me, because if the option *has been
		# chosen*, then the set of potential options is 0 because *it already
		# exists*
		# Also wouldn't that mean it would go forever? get_lowest_entropy_cell
		# will end up collecting all the cells with 1 option (which will be all
		# of them by the end), so the array would never be empty and the main
		# loop would never break?
		
		# Propagate constraints to neighboring cells
		propagate_constraints(cell)
	
	# Propagate tile constraints to adjacent cells
	func propagate_constraints(cell:Vector2i):
		# After a cell has been collapsed (an option has been chosen), we need
		# to inform all its neighbors so they can update their options
		var x:int = cell.x
		var y:int = cell.y
		const DIRECTIONS:Dictionary = {"north":Vector2i(0, -1),"south":Vector2i(0, 1),"east":Vector2i(1,0),"west":Vector2i(-1,0)}
		
		for direction in DIRECTIONS:
			var offset = DIRECTIONS[direction]
			var neighbor:Vector2i = cell + offset
			
			# Check if neighbor is within grid
			if neighbor.x >= 0 and neighbor.x < width \
			 and neighbor.y >= 0 and neighbor.y < height:
				update_entropy_v2(neighbor, grid[y][x], direction)
	
	func update_entropy_v2(cell:Vector2i, tile_that_just_got_collapsed:Tile,this_neighbors_direction_from_the_collapsed_tile:String):
		const OPPOSITE_DIRECTION = {
			"north": "south",
			"south": "north", 
			"east": "west",
			"west": "east"
		}
		# So if the cell that just got collapsed is (0,-1) and this neighbor's direction is SOUTH of that,
		# then we're standing on (0,0), and the direction to the cell that just got collapsed is NORTH
		var the_direction_to_the_cell_that_just_got_collapsed = OPPOSITE_DIRECTION[this_neighbors_direction_from_the_collapsed_tile]
		var options_the_collapsed_tile_wants_this_tile_to_be = tile_that_just_got_collapsed.options_for_direction[the_direction_to_the_cell_that_just_got_collapsed]
		var options_this_tile_is_already_constrained_to = entropy_grid[cell.y][cell.x]
		var intersection_between_what_this_tile_has_and_what_the_collapsed_tile_wants_it_to_be = []
		# one of these arrays is strings the other is Tiles so we gotta work around that
		for option in options_this_tile_is_already_constrained_to:
			var string = option.tile_name
			if options_the_collapsed_tile_wants_this_tile_to_be.has(string):
				intersection_between_what_this_tile_has_and_what_the_collapsed_tile_wants_it_to_be.append(option)
		# And now we change this cell's options to the constraints it already had, and the
		# constraints the newly collapsed cell wants for it
		if intersection_between_what_this_tile_has_and_what_the_collapsed_tile_wants_it_to_be.is_empty():
			intersection_between_what_this_tile_has_and_what_the_collapsed_tile_wants_it_to_be = [tile_that_just_got_collapsed]
		entropy_grid[cell.y][cell.x] = intersection_between_what_this_tile_has_and_what_the_collapsed_tile_wants_it_to_be
		
	# Update possible tiles for a neighboring cell
	func update_entropy(cell:Vector2i, from_direction: String):
		var x = cell.x
		var y = cell.y
		# If the neighbor has already been collapsed/decided, then we don't
		# need to update it
		if grid[y][x] != null:
			return
		
		const OPPOSITE_DIRECTION = {
			"north": "south",
			"south": "north", 
			"east": "west",
			"west": "east"
		}
		
		# Filter tiles based on connection rules
		# This part is really tricky so I'm going to break it down as best as I can
		# When we collapse a cell, we need to update the options of all its neighbors.
		# We store the options as Tiles in a list. So updating means knocking some
		# options off the list.
		# So we go through each of the options, check if each one is compatible,
		# and knock off all the ones that aren't.
		
		
		# Going through each of the options...
		var current_cells_options = entropy_grid[y][x]
		for option in current_cells_options:
			var valid = false
			# Checking if the option is valid...
			
			#region Checking if the option is valid - complicated shit, handwave
			# Alright, now for determining if an option is valid.
			# Look at all the tiles in the grid that have already been decided (why?)
			for row:Array[Tile] in grid: # Im not actually sure if its a row or col but it doesn't matter
				for existing_tile:Tile in row:

					# Cells in grid only get assigned something if they've been
					# collapsed/decided - they're all null to start with. Since
					# we're just looking at the decided ones, skip the undecided ones
					if existing_tile == null:
						continue
					if existing_tile.type == "grass":
						pass
					var opposite_direction = OPPOSITE_DIRECTION[from_direction]
					# a tiles 'type' is just its name - sand, water, grass, whatever
					# 'options_for_direction' are what options this tile allows in a certain direction.
					# So water tiles only want water or sand to connect to their
					# north side - grass isn't allowed
					var allowed_options = existing_tile.options_for_direction[opposite_direction]
					# If the option we're checking is allowed, it can stay on the list.
					# Otherwise, it'll get removed
					if allowed_options.has(option.type):
						valid = true
						break
			#endregion
			# If the option isn't valid, knock it off the list. Simple as
			if not valid:
				var options = entropy_grid[y][x]
				options.erase(option)

	func update_neighbor_entropy_v1(cell:Vector2i, from_direction: String):
		var x = cell.x
		var y = cell.y
		if grid[y][x] != null:
			return
		
		var opposite_dir = {
			"north": "south",
			"south": "north", 
			"east": "west",
			"west": "east"
		}
		
		# Filter tiles based on connection rules
		var new_entropy = []
		for tile in entropy_grid[y][x]:
			var valid = false
			for row in grid:
				for existing_tile in row:
					if existing_tile && existing_tile.options_for_direction[opposite_dir[from_direction]].has(tile.type):
						valid = true
						break
			if valid:
				new_entropy.append(tile)
		
		entropy_grid[y][x] = new_entropy
				
	# Debug print the generated grid
	func print_grid():
		for row in grid:
			var row_output = []
			for cell in row:
				row_output.append(cell.tile_name if cell else "null")
			print(row_output)
