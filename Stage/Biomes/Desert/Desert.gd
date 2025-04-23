extends Biome

func name() -> String:
	return "Desert"

func stop_scenes() -> Array[PackedScene]:
	return [
		load("res://Stage/Biomes/Desert/Stops/GridTown/Level_GridTown.tscn"),
	]

func resource_deduction_modifier() -> Dictionary:
	return {
		Item.RESOURCE_CATEGORIES.HYDRATION: 1.5,
		Item.RESOURCE_CATEGORIES.FUEL: 0.75
	}
