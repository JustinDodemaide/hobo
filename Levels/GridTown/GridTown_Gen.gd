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

var plots = [
load("res://Plots/grid town/1.tscn"),
load("res://Plots/grid town/2.tscn"),
load("res://Plots/grid town/3.tscn"),
load("res://Plots/grid town/alley.tscn"),
load("res://Plots/grid town/store_plot.tscn"),
]

func generate():
	tracks()
	terrain_mesh()
	building_layout()

func building_layout():
	# first value is left right
	# second is up down
	const SPACE_FROM_EDGES:int = 1
	const MAX_BLOCK_WIDTH:int = 6
	const MIN_BLOCK_WIDTH:int = 2
	
	var row = SPACE_FROM_EDGES
	while row < LENGTH:
		var street = SPACE_FROM_EDGES
		while street < WIDTH:
			if tget(buildings, Vector2i(street,row)) == TRACKS:
				street += 1
				continue
			tset(buildings, Vector2i(street,row), STREET)
			street += 1
		
		row += 1
		
		var intersection = randi_range(MIN_BLOCK_WIDTH, MAX_BLOCK_WIDTH)
		var block = SPACE_FROM_EDGES
		while block < WIDTH:
			var tile = Vector2i(block,row)
			if tget(buildings, tile) == TRACKS:
				block += 1
				continue
			tset(buildings, tile, PLOT)
			if block == intersection:
				tset(buildings, tile, STREET)
				intersection += randi_range(MIN_BLOCK_WIDTH, MAX_BLOCK_WIDTH)
			else:
				tset(buildings, tile, PLOT)
				place_structure(tile)
			block += 1
			
		row += 1
		
	var citizen_handler = load("res://Levels/GridTown/CitizenHandler/CitizenHandler.tscn").instantiate()
	level.add_child(citizen_handler)

var offset = 0.0
func place_structure(tile):
	offset += 0.0001 # Need to offset the hieghts of adjacent plots to prevent foundation z-fighting
	var cell = tile * TILE_TO_METER_RATIO
	var plot = plots.pick_random().instantiate()
	var height = get_height(tile) + offset
	plot.position = Vector3(cell.x, height, cell.y)
	level.add_child(plot)

func tracks():
	var tracks = level.get_node("Tracks")
	tracks.global_position.x = WIDTH/2 * TILE_TO_METER_RATIO
	tracks.global_position.z = LENGTH * TILE_TO_METER_RATIO

func path() -> void:
	const CURVE_DEPTH:int = 30
	var station = Vector2i(WIDTH/2, LENGTH/3)
	var curve = Curve3D.new()
	for x in range(-WIDTH,WIDTH):
		var y = (x*x) / CURVE_DEPTH
		var tile = Vector2i(x,y) + station
		tset(buildings,tile,TRACKS)
		var cell = Vector3(tile.x * TILE_TO_METER_RATIO, 0, tile.y * TILE_TO_METER_RATIO)
		curve.add_point(cell)
	tset(buildings,station,STATION)
	level.path.curve = curve

func terrain_mesh() -> void:
	var ground = preload("res://Levels/GridTown/Ground/GridTownGround.tscn").instantiate()
	ground.init(self)
	level.add_child(ground)

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
