class_name TerrainGen

enum {GRASSLAND}
func set_terrain(gen:LevelGen, preset:int) -> void:
	match preset:
		GRASSLAND:
			grassland(gen)

func grassland(gen:LevelGen) -> void:
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC
	noise.frequency = 0.1
	for x in gen.WIDTH:
		for y in gen.LENGTH:
			var tile = Vector2i(x,y)
			var val = round((noise.get_noise_2dv(tile) + 1) * 10)
			gen.tset(gen.terrain, tile, gen.GROUND)
