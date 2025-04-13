class_name Stage

var biome:Biome
var _biomes = {
	"Desert":load("res://Stage/Biomes/Desert/Desert.gd").new()
}

var number_of_stops:int = 3
var stops = []
var current_stop:int = 0

var map

func generate():
	biome = _biomes[_biomes.keys().pick_random()]
	var possible_stops = biome.stop_scenes()
	for i in number_of_stops:
		stops.append(possible_stops.pick_random()) # Probably want a score-based selection method

func make_map():
	map = load("res://Stage/StageMap/StageMap.tscn").instantiate()
	map.generate(biome.map_info())

func progress():
	current_stop += 1
	
