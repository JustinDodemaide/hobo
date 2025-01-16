var tiles
func get_tiles(setup_name:String) -> Array:
	match setup_name:
		"coastal":
			setup_coastal_biome()
		"forest":
			setup_forest_biome()
		"town":
			setup_town_tiles()
		"fishing village":
			setup_fishing_village()
		"road":
			setup_road()
	return tiles

func setup_coastal_biome():
	tiles = [
		Tile.new("deep_water",Vector2i(46,0)),
		Tile.new("shallow_water",Vector2i(47,0)),
		Tile.new("beach",Vector2i(63,0)),
		Tile.new("grass",Vector2i(30,0)),
		#Tile.new("building",Vector2i(6,0)),
		#Tile.new("dock")
	]
	
	# Deep water can only have deep water to its "ocean side" (north in this case)
	tiles[0].options_for_direction = {
		"north": ["deep_water"],  # Ocean direction
		"south": ["deep_water", "shallow_water"],  # Towards shore
		"east": ["deep_water"],  # Keep ocean connected
		"west": ["deep_water"]   # Keep ocean connected
	}

	# Shallow water transitions between deep water and beach
	tiles[1].options_for_direction = {
		"north": ["deep_water", "shallow_water"],  # Towards ocean
		"south": ["shallow_water", "beach"],       # Towards shore
		"east": ["shallow_water"],                 # Keep waterline connected
		"west": ["shallow_water"]                  # Keep waterline connected
	}

	# Beach only connects to shallow water on ocean side, grass/buildings on land side
	tiles[2].options_for_direction = {
		"north": ["shallow_water"],                # Towards ocean
		"south": ["grass", "beach"],               # Towards inland
		"east": ["beach"],                         # Keep beachline connected
		"west": ["beach"]                          # Keep beachline connected
	}
	
	# Grass
	tiles[3].options_for_direction = {
		"north": ["beach", "grass"],
		"south": [ "grass"],
		"east": ["beach", "grass"],
		"west": ["beach", "grass"]
	}
	
	## Building
	#tiles[4].options_for_direction = {
		#"north": ["grass","building","beach"],
		#"south": ["grass","building"],
		#"east": ["grass","building"],
		#"west": ["grass","building"]
	#}

# Define tile connection rules for different biomes
func setup_lakes_biome():
	# Example tile types for a coastal biome
	tiles = [
		Tile.new("water",Vector2i(47,0)),
		Tile.new("sand",Vector2i(63,0)),
		Tile.new("grass",Vector2i(30,0)),
		#Tile.new(3, "fishing_hut"),
		#Tile.new(4, "dock")
	]
	
	# Define connection rules
	tiles[0].options_for_direction = {
		"north": ["water", "sand"],
		"south": ["water", "sand"],
		"east": ["water", "sand"],
		"west": ["water", "sand"]
	}
	#sand
	tiles[1].options_for_direction = {
		"north": ["water", "sand", "grass"],
		"south": ["water", "sand", "grass"],
		"east": ["water", "sand", "grass"],
		"west": ["water", "sand", "grass"]
	}
	
	tiles[2].options_for_direction = {
		"north": ["sand", "grass"],
		"south": ["sand", "grass"],
		"east": ["sand", "grass"],
		"west": ["sand", "grass"]
	}
	# ... add more connection rules for other tiles

func setup_forest_biome():
	# Basic natural tiles
	tiles = [
		Tile.new("dense_forest", Vector2i(34,0)),  # Deep Forest Green
		Tile.new("light_forest", Vector2i(35,0)),  # Medium Forest Green
		Tile.new("clearing", Vector2i(31,0)),      # Light Green
		Tile.new("river", Vector2i(47,0)),         # Light Sky Blue
		Tile.new("riverbank", Vector2i(41,0))      # Light Turquoise
	]
	
	# Dense forest - Creates natural boundaries
	tiles[0].options_for_direction = {
		"north": ["dense_forest", "light_forest"],
		"south": ["dense_forest", "light_forest"],
		"east": ["dense_forest", "light_forest"],
		"west": ["dense_forest", "light_forest"]
	}
	
	# Light forest - Main traversable area
	tiles[1].options_for_direction = {
		"north": ["dense_forest", "light_forest", "clearing", "riverbank"],
		"south": ["dense_forest", "light_forest", "clearing", "riverbank"],
		"east": ["dense_forest", "light_forest", "clearing", "riverbank"],
		"west": ["dense_forest", "light_forest", "clearing", "riverbank"]
	}
	
	# Clearing - Natural open spaces
	tiles[2].options_for_direction = {
		"north": ["light_forest", "clearing"],
		"south": ["light_forest", "clearing"],
		"east": ["light_forest", "clearing"],
		"west": ["light_forest", "clearing"]
	}
	
	# River
	tiles[3].options_for_direction = {
		"north": ["river", "riverbank"],
		"south": ["river", "riverbank"],
		"east": ["river", "riverbank"],
		"west": ["river", "riverbank"]
	}
	
	# Riverbank - Transition between water and land
	tiles[4].options_for_direction = {
		"north": ["river", "riverbank", "light_forest"],
		"south": ["river", "riverbank", "light_forest"],
		"east": ["river", "riverbank", "light_forest"],
		"west": ["river", "riverbank", "light_forest"]
	}

func setup_town_tiles():
	tiles = [
		Tile.new("top_right_corner", Vector2i(0,0)),
		Tile.new("bottom_right_corner", Vector2i(0,0)),
		Tile.new("top_left_corner", Vector2i(0,0)),
		Tile.new("bottom_left_corner", Vector2i(0,0)),
		Tile.new("top_building", Vector2i(0,0)),
		Tile.new("bottom_building", Vector2i(0,0)),
		Tile.new("vertical_road", Vector2i(6,0)),
		Tile.new("horizontal_road", Vector2i(6,0))
	]
	
	# Top Right Corner
	tiles[0].options_for_direction = {
		"south": ["bottom_right_corner"],
		"north": ["horizontal_road"],
		"east": ["vertical_road"],
		"west": ["top_building"]
	}
	
	# Bottom Right Corner
	tiles[1].options_for_direction = {
		"north": ["top_right_corner"],
		"south": ["horizontal_road"],
		"east": ["vertical_road"],
		"west": ["bottom_building"]
	}
	
	# Top Left Corner
	tiles[2].options_for_direction = {
		"south": ["bottom_left_corner"],
		"north": ["horizontal_road"],
		"east": ["top_building"],
		"west": ["vertical_road"]
	}
	
	# Bottom Left Corner
	tiles[3].options_for_direction = {
		"north": ["top_left_corner"],
		"south": ["horizontal_road"],
		"east": ["bottom_building"],
		"west": ["vertical_road"]
	}
	
	# Top Building
	tiles[4].options_for_direction = {
		"north": ["horizontal_road"],
		"south": ["bottom_building"],
		"east": ["top_building", "top_right_corner"],
		"west": ["top_building", "top_left_corner"]
	}
	
	# Bottom Building
	tiles[5].options_for_direction = {
		"north": ["top_building"],
		"south": ["horizontal_road"],
		"east": ["bottom_building", "bottom_right_corner"],
		"west": ["bottom_building", "bottom_left_corner"]
	}
	
	# Vertical road
	tiles[6].options_for_direction = {
		"north": ["vertical_road", "bottom_building"],
		"south": ["vertical_road", "top_building"],
		"east": ["horizontal_road", "top_left_corner", "bottom_left_corner"],
		"west": ["horizontal_road", "top_right_corner", "bottom_right_corner"]
	}
	
	# Horizontal road
	tiles[7].options_for_direction = {
		"north": ["bottom_building", "bottom_right_corner", "bottom_left_corner"],
		"south": ["top_building", "top_right_corner", "top_left_corner"],
		"east": ["horizontal_road", "vertical_road"],
		"west": ["horizontal_road", "vertical_road"]
	}

func setup_fishing_village():
	# Using colors from palette that evoke weathered wood, murky water, and worn paths
	tiles = [
		# Natural/Base tiles
		Tile.new("deep_water", Vector2i(43,0)),  # Navy blue for deep water
		Tile.new("shallow_water", Vector2i(46,0)),  # Bright blue for shallows
		Tile.new("beach", Vector2i(62,0)),  # Light peach for sandy areas
		Tile.new("muddy_path", Vector2i(20,0)),  # Deep rust for worn dirt paths
		Tile.new("grass", Vector2i(37,0)),  # Pale sage for coastal grass
		
		# Structure tiles
		Tile.new("pier", Vector2i(34,0)),  # Dark forest green for weathered wood
		Tile.new("dock", Vector2i(35,0)),  # Forest green for newer wood
		Tile.new("shack", Vector2i(54,0)),  # Mauve for weather-beaten buildings
		Tile.new("net_rack", Vector2i(36,0)),  # Medium forest green for equipment
		Tile.new("fish_market", Vector2i(20,0)),  # Deep rust for bustling areas
		Tile.new("storage", Vector2i(33,0))  # Dark gray for storage sheds
	]
	
	# Deep water - Creates boundaries and fishing spots
	tiles[0].options_for_direction = {
		"north": ["deep_water", "shallow_water"],
		"south": ["deep_water", "shallow_water"],
		"east": ["deep_water", "shallow_water"],
		"west": ["deep_water", "shallow_water"]
	}
	
	# Shallow water - Transition between deep water and land
	tiles[1].options_for_direction = {
		"north": ["deep_water", "shallow_water", "pier", "dock"],
		"south": ["deep_water", "shallow_water", "pier", "dock"],
		"east": ["deep_water", "shallow_water", "pier", "dock"],
		"west": ["deep_water", "shallow_water", "pier", "dock"]
	}
	
	# Beach - Natural transition zone
	tiles[2].options_for_direction = {
		"north": ["shallow_water", "beach", "muddy_path", "pier"],
		"south": ["beach", "muddy_path", "grass"],
		"east": ["beach", "muddy_path", "pier", "dock"],
		"west": ["beach", "muddy_path", "pier", "dock"]
	}
	
	# Muddy path - Main navigation routes
	tiles[3].options_for_direction = {
		"north": ["beach", "muddy_path", "shack", "fish_market", "storage"],
		"south": ["muddy_path", "grass", "shack", "fish_market", "storage"],
		"east": ["muddy_path", "shack", "fish_market", "storage"],
		"west": ["muddy_path", "shack", "fish_market", "storage"]
	}
	
	# Grass - Inland areas
	tiles[4].options_for_direction = {
		"north": ["muddy_path", "grass", "shack", "storage"],
		"south": ["grass", "shack", "storage"],
		"east": ["grass", "shack", "storage"],
		"west": ["grass", "shack", "storage"]
	}
	
	# Pier - Extended structures over water
	tiles[5].options_for_direction = {
		"north": ["shallow_water", "pier"],
		"south": ["beach", "dock", "pier"],
		"east": ["shallow_water", "pier", "dock"],
		"west": ["shallow_water", "pier", "dock"]
	}
	
	# Dock - Working areas
	tiles[6].options_for_direction = {
		"north": ["shallow_water", "pier", "dock"],
		"south": ["beach", "muddy_path", "net_rack"],
		"east": ["pier", "dock", "net_rack"],
		"west": ["pier", "dock", "net_rack"]
	}
	
	# Shack - Residential/work buildings
	tiles[7].options_for_direction = {
		"north": ["muddy_path", "grass"],
		"south": ["muddy_path", "grass"],
		"east": ["muddy_path", "grass", "storage", "net_rack"],
		"west": ["muddy_path", "grass", "storage", "net_rack"]
	}
	
	# Net rack - Equipment areas
	tiles[8].options_for_direction = {
		"north": ["dock", "muddy_path"],
		"south": ["muddy_path", "grass"],
		"east": ["muddy_path", "shack", "storage"],
		"west": ["muddy_path", "shack", "storage"]
	}
	
	# Fish market - Commercial hub
	tiles[9].options_for_direction = {
		"north": ["muddy_path", "storage"],
		"south": ["muddy_path"],
		"east": ["muddy_path", "storage"],
		"west": ["muddy_path", "storage"]
	}
	
	# Storage - Utility buildings
	tiles[10].options_for_direction = {
		"north": ["muddy_path", "grass"],
		"south": ["muddy_path", "grass"],
		"east": ["muddy_path", "grass", "shack", "fish_market"],
		"west": ["muddy_path", "grass", "shack", "fish_market"]
	}

enum {NORTH_EAST_SOUTH_WEST,NORTH_EAST_SOUTH,NORTH_WEST_SOUTH,EAST_NORTH_WEST,EAST_NORTH_SOUTH,SOUTH_EAST,NORTH_EAST,NORTH_WEST,SOUTH_WEST,NORTH_SOUTH,EAST_WEST,BUILDING}
func setup_road():
	# Example tile types for a coastal biome
	tiles = [
		Tile.new("NORTH_EAST_SOUTH_WEST",Vector2i(NORTH_EAST_SOUTH_WEST,0)),
		Tile.new("NORTH_EAST_SOUTH",Vector2i(NORTH_EAST_SOUTH,0)),
		Tile.new("NORTH_WEST_SOUTH",Vector2i(NORTH_WEST_SOUTH,0)),
		Tile.new("EAST_NORTH_WEST",Vector2i(EAST_NORTH_WEST,0)),
		Tile.new("EAST_NORTH_SOUTH",Vector2i(EAST_NORTH_SOUTH,0)),
		Tile.new("SOUTH_EAST",Vector2i(SOUTH_EAST,0)),
		Tile.new("NORTH_EAST",Vector2i(NORTH_EAST,0)),
		Tile.new("NORTH_WEST",Vector2i(NORTH_WEST,0)),
		Tile.new("SOUTH_WEST",Vector2i(SOUTH_WEST,0)),
		Tile.new("NORTH_SOUTH",Vector2i(NORTH_SOUTH,0)),
		Tile.new("EAST_WEST",Vector2i(EAST_WEST,0)),
		Tile.new("BUILDING",Vector2i(BUILDING,0)),
	]
	
	# Four-way intersection - Can connect to anything with matching directions
	tiles[NORTH_EAST_SOUTH_WEST].options_for_direction = {
		"north": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "NORTH_WEST_SOUTH", "EAST_NORTH_WEST", "EAST_NORTH_SOUTH", "NORTH_EAST", "NORTH_WEST", "NORTH_SOUTH"],
		"east": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "EAST_NORTH_WEST", "EAST_NORTH_SOUTH", "SOUTH_EAST", "NORTH_EAST", "EAST_WEST"],
		"south": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "NORTH_WEST_SOUTH", "SOUTH_EAST", "SOUTH_WEST", "NORTH_SOUTH"],
		"west": ["NORTH_EAST_SOUTH_WEST", "NORTH_WEST_SOUTH", "EAST_NORTH_WEST", "NORTH_WEST", "SOUTH_WEST", "EAST_WEST"]
	}
	
	# Three-way intersections
	tiles[NORTH_EAST_SOUTH].options_for_direction = {
		"north": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "NORTH_WEST_SOUTH", "EAST_NORTH_WEST", "EAST_NORTH_SOUTH", "NORTH_EAST", "NORTH_WEST", "NORTH_SOUTH"],
		"east": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "EAST_NORTH_WEST", "EAST_NORTH_SOUTH", "SOUTH_EAST", "NORTH_EAST", "EAST_WEST"],
		"south": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "NORTH_WEST_SOUTH", "SOUTH_EAST", "SOUTH_WEST", "NORTH_SOUTH"],
		"west": ["BUILDING"]
	}
	
	tiles[NORTH_WEST_SOUTH].options_for_direction = {
		"north": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "NORTH_WEST_SOUTH", "EAST_NORTH_WEST", "EAST_NORTH_SOUTH", "NORTH_EAST", "NORTH_WEST", "NORTH_SOUTH"],
		"east": ["BUILDING"],
		"south": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "NORTH_WEST_SOUTH", "SOUTH_EAST", "SOUTH_WEST", "NORTH_SOUTH"],
		"west": ["NORTH_EAST_SOUTH_WEST", "NORTH_WEST_SOUTH", "EAST_NORTH_WEST", "NORTH_WEST", "SOUTH_WEST", "EAST_WEST"]
	}
	
	tiles[EAST_NORTH_WEST].options_for_direction = {
		"north": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "NORTH_WEST_SOUTH", "EAST_NORTH_WEST", "EAST_NORTH_SOUTH", "NORTH_EAST", "NORTH_WEST", "NORTH_SOUTH"],
		"east": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "EAST_NORTH_WEST", "EAST_NORTH_SOUTH", "SOUTH_EAST", "NORTH_EAST", "EAST_WEST"],
		"south": ["BUILDING"],
		"west": ["NORTH_EAST_SOUTH_WEST", "NORTH_WEST_SOUTH", "EAST_NORTH_WEST", "NORTH_WEST", "SOUTH_WEST", "EAST_WEST"]
	}
	
	tiles[EAST_NORTH_SOUTH].options_for_direction = {
		"north": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "NORTH_WEST_SOUTH", "EAST_NORTH_WEST", "EAST_NORTH_SOUTH", "NORTH_EAST", "NORTH_WEST", "NORTH_SOUTH"],
		"east": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "EAST_NORTH_WEST", "EAST_NORTH_SOUTH", "SOUTH_EAST", "NORTH_EAST", "EAST_WEST"],
		"south": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "NORTH_WEST_SOUTH", "SOUTH_EAST", "SOUTH_WEST", "NORTH_SOUTH"],
		"west": ["BUILDING"]
	}
	
	# Corner pieces
	tiles[SOUTH_EAST].options_for_direction = {
		"north": ["BUILDING"],
		"east": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "EAST_NORTH_WEST", "EAST_NORTH_SOUTH", "SOUTH_EAST", "NORTH_EAST", "EAST_WEST"],
		"south": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "NORTH_WEST_SOUTH", "SOUTH_EAST", "SOUTH_WEST", "NORTH_SOUTH"],
		"west": ["BUILDING"]
	}
	
	tiles[NORTH_EAST].options_for_direction = {
		"north": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "NORTH_WEST_SOUTH", "EAST_NORTH_WEST", "EAST_NORTH_SOUTH", "NORTH_EAST", "NORTH_WEST", "NORTH_SOUTH"],
		"east": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "EAST_NORTH_WEST", "EAST_NORTH_SOUTH", "SOUTH_EAST", "NORTH_EAST", "EAST_WEST"],
		"south": ["BUILDING"],
		"west": ["BUILDING"]
	}
	
	tiles[NORTH_WEST].options_for_direction = {
		"north": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "NORTH_WEST_SOUTH", "EAST_NORTH_WEST", "EAST_NORTH_SOUTH", "NORTH_EAST", "NORTH_WEST", "NORTH_SOUTH"],
		"east": ["BUILDING"],
		"south": ["BUILDING"],
		"west": ["NORTH_EAST_SOUTH_WEST", "NORTH_WEST_SOUTH", "EAST_NORTH_WEST", "NORTH_WEST", "SOUTH_WEST", "EAST_WEST"]
	}
	
	tiles[SOUTH_WEST].options_for_direction = {
		"north": ["BUILDING"],
		"east": ["BUILDING"],
		"south": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "NORTH_WEST_SOUTH", "SOUTH_EAST", "SOUTH_WEST", "NORTH_SOUTH"],
		"west": ["NORTH_EAST_SOUTH_WEST", "NORTH_WEST_SOUTH", "EAST_NORTH_WEST", "NORTH_WEST", "SOUTH_WEST", "EAST_WEST"]
	}
	
	# Straight pieces
	tiles[NORTH_SOUTH].options_for_direction = {
		"north": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "NORTH_WEST_SOUTH", "EAST_NORTH_WEST", "EAST_NORTH_SOUTH", "NORTH_EAST", "NORTH_WEST", "NORTH_SOUTH"],
		"east": ["BUILDING"],
		"south": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "NORTH_WEST_SOUTH", "SOUTH_EAST", "SOUTH_WEST", "NORTH_SOUTH"],
		"west": ["BUILDING"]
	}
	
	tiles[EAST_WEST].options_for_direction = {
		"north": ["BUILDING"],
		"east": ["NORTH_EAST_SOUTH_WEST", "NORTH_EAST_SOUTH", "EAST_NORTH_WEST", "EAST_NORTH_SOUTH", "SOUTH_EAST", "NORTH_EAST", "EAST_WEST"],
		"south": ["BUILDING"],
		"west": ["NORTH_EAST_SOUTH_WEST", "NORTH_WEST_SOUTH", "EAST_NORTH_WEST", "NORTH_WEST", "SOUTH_WEST", "EAST_WEST"]
	}
	
	# Building - Can connect to any non-connecting side of road pieces
	tiles[BUILDING].options_for_direction = {
		"north": ["SOUTH_EAST", "SOUTH_WEST", "EAST_WEST", "BUILDING"],
		"east": ["NORTH_WEST_SOUTH", "NORTH_WEST", "SOUTH_WEST", "NORTH_SOUTH", "BUILDING"],
		"south": ["NORTH_EAST", "NORTH_WEST", "EAST_WEST", "BUILDING"],
		"west": ["NORTH_EAST_SOUTH", "EAST_NORTH_SOUTH", "SOUTH_EAST", "NORTH_EAST", "NORTH_SOUTH", "BUILDING"]
	}
