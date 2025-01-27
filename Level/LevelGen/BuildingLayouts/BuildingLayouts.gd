class_name BuildingLayouts

enum {GRID}
func set_buildings(gen:LevelGen, preset:int) -> void:
	match preset:
		GRID:
			grid(gen)

func grid(gen:LevelGen) -> void:
	const SPACE_FROM_EDGES:int = 2
	const MAX_BLOCK_WIDTH:int = 6
	for x in range(SPACE_FROM_EDGES, gen.WIDTH - SPACE_FROM_EDGES):
		for y in range(SPACE_FROM_EDGES, gen.LENGTH - SPACE_FROM_EDGES):
			gen.tset(gen.buildings, Vector2i(x,y), gen.PLOT)
	
	for y in range(SPACE_FROM_EDGES, gen.LENGTH - SPACE_FROM_EDGES, 2):
		for x in range(SPACE_FROM_EDGES, gen.WIDTH - SPACE_FROM_EDGES):
			# Fill in the row
			gen.tset(gen.buildings, Vector2i(x,y), gen.STREET)
		
		# Place side streets connecting rows
		var intersections = []
		var x = 0
		while x < gen.WIDTH - SPACE_FROM_EDGES:
			x += randi_range(2,MAX_BLOCK_WIDTH)
			if x > gen.WIDTH - (SPACE_FROM_EDGES + SPACE_FROM_EDGES):
				break
			intersections.append(x)
		for i in intersections:
			var side_street = Vector2i(i,y - 1)
			gen.tset(gen.buildings, side_street, gen.STREET)
