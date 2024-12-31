extends TileMapLayer

const CARDINALS:Dictionary = {
	"N":Vector2i(0,-1),
	"S":Vector2i(0,1),
	"E":Vector2i(1,0),
	"W":Vector2i(-1,0),
	
	"NE":Vector2i(1,-1),
	"NW":Vector2i(-1,-1),
	"SE":Vector2i(1,1),
	"SW":Vector2i(-1,1)
}

const GRID_SIZE:int = 9
const n:int = 1
func _ready() -> void:
	var center = Vector2i(5,5)
	var valid_tiles:Array[Vector2i] = []
	var visited:Array[Vector2i] = [center]
	
	# BFS queue: store (coords, distance)
	var queue := [{"tile":center,"distance":0}]
	while !queue.is_empty():
		Log.prn(queue)
		var current = queue.pop_front()
		var tile = current.tile
		var distance = current.distance
		if distance > n:
			valid_tiles.append(tile)
			continue
		for direction in CARDINALS:
			var neighbor = tile + CARDINALS[direction]
			if neighbor.x >= GRID_SIZE and neighbor.y >= GRID_SIZE:
				continue
			if visited.has(neighbor):
				continue
			visited.append(neighbor)
			queue.append({"tile":neighbor,"distance":distance + 1})
	for i in valid_tiles:
		set_cell(i,0,Vector2i(31,0))

	
#from collections import deque
#
#def find_safe_tiles(grid, fire_position, n):
	#rows, cols = len(grid), len(grid[0])
	#fire_x, fire_y = fire_position
	#visited = set()
	#safe_tiles = []
#
	## Define directions for neighbors (up, down, left, right)
	#directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
#
	## BFS queue: store (x, y, distance)
	#queue = deque([(fire_x, fire_y, 0)])
	#visited.add((fire_x, fire_y))
#
	#while queue:
		#x, y, dist = queue.popleft()
#
		## If the current distance equals n, this tile is safe
		#if dist == n:
			#safe_tiles.append((x, y))
			#continue  # Don't explore further from this tile
#
		## Explore neighbors
		#for dx, dy in directions:
			#nx, ny = x + dx, y + dy
			#if 0 <= nx < rows and 0 <= ny < cols and (nx, ny) not in visited:
				#visited.add((nx, ny))
				#queue.append((nx, ny, dist + 1))
#
	#return safe_tiles
#
## Example usage
#grid = [
	#['.', '.', '.'],
	#['.', 'F', '.'],
	#['.', '.', '.']
#]  # '.' is air, 'F' is fire
#fire_position = (1, 1)  # Fire is at the center
#n = 2
#
#safe_tiles = find_safe_tiles(grid, fire_position, n)
#print("Safe tiles at distance n:", safe_tiles)
