class_name Biome

func name() -> String:
	return "Biome"

func stop_scenes() -> Array[PackedScene]:
	return [
		
	]

# Each collectable item is in a resource category
# RESOURCE_CATEGORIES {A, B, C, D, E}
# Different biomes might deplete more of some resources than others
# Each value is just a multiplier. A: 1.5 means "lose 1.5 times more of A than default"
func resource_deduction_modifier() -> Dictionary:
	return {
		
	}

func map_info() -> Dictionary:
	return {
		"terrain_color":Color(0.6671, 0.5923, 0.3768, 1.0)

	}
