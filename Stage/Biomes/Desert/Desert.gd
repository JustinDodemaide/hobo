extends Biome

func name() -> String:
	return "Desert"

func stop_scenes() -> Array[PackedScene]:
	return [
		load("res://Stage/Biomes/Desert/Stops/GridTown/Level_GridTown.tscn"),
	]
