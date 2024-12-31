extends TileMapLayer

const LEVEL_SIZE = 100
const ROAD_DENSITY:float = 0.5
const BUIDLING_DENSITY:float = 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in LEVEL_SIZE:
		for y in LEVEL_SIZE:
			var tile = Vector2i(x,y)
			if is_road(tile, 0.5):
				set_cell(tile,0,Vector2i(34,0))
			
			if is_empty(tile) and randi

	## Step 3: Place buildings
	#for row in range(gridHeight):
		#for col in range(gridWidth):
			#if grid[row][col] == 'empty' and randomChance(buildingDensity):
				#grid[row][col] = 'building'
#
	## Step 4: Add landmarks or features
	#placeLandmarks(grid)  # Add special buildings (e.g., town hall, parks)
#
	## Step 5: Ensure connectivity
	#ensureRoadConnectivity(grid)
#
	#return grid
#
func is_road(where:Vector2i, road_density):
	if where % 4 == Vector2i.ZERO:
		return true
	if randi() % 2 == 0:
		return true
	return false
## Helper function to determine road placement
#function isRoad(row, col, roadDensity):
	## Create a grid pattern for roads
	#if row % 4 == 0 or col % 4 == 0:  # Roads every 4 cells
		#return true
	## Add randomness to break uniformity
	#return randomChance(roadDensity)
#
## Helper function to place landmarks
#function placeLandmarks(grid):
	## Example: Place a landmark near the center
	#centerRow = grid.length // 2
	#centerCol = grid[0].length // 2
	#grid[centerRow][centerCol] = 'landmark'
#
## Helper function to ensure all roads are connected
#function ensureRoadConnectivity(grid):
	## Implement a pathfinding algorithm (e.g., BFS) to verify connectivity
	## Add missing roads if necessary to ensure all areas are reachable
	#roadPositions = findAllRoads(grid)
	#for road in roadPositions:
		#if not isReachable(road, roadPositions):
			#connectToClosestRoad(grid, road)
#
## Utility function for random chance
#function randomChance(probability):
	#return random() < probability  # Random number [0, 1) < probability
#
## Utility function to create an empty grid
#function createEmptyGrid(width, height):
	#return [['empty' for _ in range(width)] for _ in range(height)]
