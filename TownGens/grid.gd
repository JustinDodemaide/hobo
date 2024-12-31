extends TileMapLayer

var width = 20
var height = 20
var max_block_length = 3

func noise() -> void:
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_VALUE
	noise.frequency = 0.1
	
	var lowest = 10000
	var highest = -10000
	for y in height:
		for x in width:
			var where = Vector2(x,y)
			var val = noise.get_noise_2dv(where)
			if val < lowest:
				lowest = val
			if val > highest:
				highest = val
	print("lowest: ", lowest)
	print("highest: ", highest)
	
	var shore_tiles = []

	var num_steps = 10
	var step = (highest - lowest) / num_steps
	var water_level = 1
	for y in height:
		for x in width:
			var where = Vector2(x,y)
			var val = noise.get_noise_2dv(where)
			var color = 0
			for i in num_steps:
				if (val >= lowest + i * step && val < lowest + (i + 1) * step):
					if i <= water_level:
						set_cell(where,0,Vector2i(40,0))
						shore_tiles.append(where)
						continue
					if i == water_level + 1:
						set_cell(where,0,Vector2i(14,0))
						
						continue
					set_cell(where,0,Vector2i(i,0))
	
	shore_tiles.shuffle()
	var number_of_huts = 7
	for i in number_of_huts:
		var where = shore_tiles[i]
		set_cell(where,0,Vector2i(20,0))

			#if (val >= lowest && val < lowest + step):
				#color = 0
			#if (val >= lowest + step && val < lowest + 2 * step):
				#color = 1
			#if (val >= lowest + 2 * step && val < lowest + 3 * step):
				#color = 2
			#if (val >= lowest + 3 * step && val < lowest + 4 * step):
				#color = 3
			#if(val >= lowest + 4 * step && val <= highest):
				#color = 4

			#var interpolated = round(((val + 0.11401679366827) / 0.21560022234917) * 4)
			#print(interpolated)
			#var water_level = 0
			#if color <= water_level:
				#set_cell(where,0,Vector2i(40,0))
			#else:
				#set_cell(where,0,Vector2i(color+29,0))

func _ready() -> void:
	for y in range(1,height,2):
		for x in width:
			s(Vector2i(x,y))
			
	for y in range(0,height,2):
		var x = 0
		while x < 0:
			
			x += randi_range(1,3)

		#var x = 0
		#while x < width:
			#x += randi_range(1,max_block_length)
			#if x == 0:
				#pass
			#s(Vector2i(x,y))


func s(where):
	set_cell(where,0,Vector2i(0,0))
