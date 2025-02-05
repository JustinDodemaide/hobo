extends Node

enum{GROUND,WATER}
@onready var terrain:TileMapLayer = $Terrain
enum{STREET,PLOT,TRACKS,STATION}
@onready var buildings:TileMapLayer = $Buildings
var heights:Array = []

var level:Level
const LENGTH:int = 35
const WIDTH:int = 35

const TILE_TO_METER_RATIO:int = 10

const plots = [
"res://Plots/grid town/store_plot.tscn",
"res://Plots/grid town/alley_plot.tscn",
"res://Plots/grid town/misc_building2.tscn",
"res://Plots/grid town/misc_building4.tscn",
"res://Plots/grid town/misc_building5.tscn",
]

func generate():
	building_layout()
	path()
	terrain_mesh()
	structures()

func building_layout():
	const SPACE_FROM_EDGES:int = 1
	
	const MAX_BLOCK_WIDTH:int = 6
	for x in range(SPACE_FROM_EDGES, WIDTH - SPACE_FROM_EDGES):
		for y in range(SPACE_FROM_EDGES, LENGTH - SPACE_FROM_EDGES):
			tset(buildings, Vector2i(x,y), PLOT)
	
	for y in range(SPACE_FROM_EDGES, LENGTH - SPACE_FROM_EDGES, 2):
		for x in range(SPACE_FROM_EDGES, WIDTH - SPACE_FROM_EDGES):
			# Fill in the row
			tset(buildings, Vector2i(x,y), STREET)
		
		# Place side streets connecting rows
		var intersections = []
		var x = 0
		while x < WIDTH - SPACE_FROM_EDGES:
			x += randi_range(2,MAX_BLOCK_WIDTH)
			if x > WIDTH - (SPACE_FROM_EDGES + SPACE_FROM_EDGES):
				break
			intersections.append(x)
		for i in intersections:
			var side_street = Vector2i(i,y - 1)
			tset(buildings, side_street, STREET)

func path() -> void:
	const CURVE_DEPTH:int = 30
	var station = Vector2i(WIDTH/2, LENGTH/3)
	var curve = Curve3D.new()
	#var curve_vector_y = TILE_TO_METER_RATIO / 2
	#var last_point = null
	for x in range(-WIDTH,WIDTH):
		var y = (x*x) / CURVE_DEPTH
		var tile = Vector2i(x,y) + station
		tset(buildings,tile,TRACKS)
		var cell = Vector3(tile.x * TILE_TO_METER_RATIO, 0, tile.y * TILE_TO_METER_RATIO)
		#Log.prn(cell)
		#if !last_point:
		#	curve.add_point(cell), Vector3(-curve_vector_y,0,0), Vector3(curve_vector_y,0,0))
		curve.add_point(cell)#, Vector3(-curve_vector_y,0,0), Vector3(curve_vector_y,0,0))
	tset(buildings,station,STATION)
	level.path.curve = curve

func terrain_mesh() -> void:
	var ground = load("res://Levels/GridTown/Ground/GridTownGround.tscn").instantiate()
	ground.init(self)
	level.add_child(ground)

func structures():
	var offset = 0.0001
	# Need to offset the hieghts of adjacent plots to prevent foundation z-fighting
	for tile in buildings.get_used_cells_by_id(0, Vector2i(PLOT, 0)):
		var cell = tile * TILE_TO_METER_RATIO
		var plot = load(plots.pick_random()).instantiate()
		var height = get_height(tile) + offset
		plot.position = Vector3(cell.x, height, cell.y)
		level.add_child(plot)
		
		offset += 0.0001

func tset(which:TileMapLayer,where:Vector2i,what:int):
	which.set_cell(where, 0, Vector2i(what, 0))

func tget(which:TileMapLayer,where:Vector2i) -> int:
	return which.get_cell_atlas_coords(where).x

func get_height(where:Vector2i):
	return 0

func _process(_delta: float) -> void:
	var player = level.get_node("Player")
	if not player:
		return
	var pos = player.global_position / TILE_TO_METER_RATIO
	var tile = Vector2(pos.x,pos.z) * 8
	$Sprite2D.position = tile
