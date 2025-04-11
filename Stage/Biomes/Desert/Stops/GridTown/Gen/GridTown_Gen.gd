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
load("res://Levels/GridTown/Buildings/Building1/1.tscn"),
load("res://Levels/GridTown/Buildings/Building2/2.tscn"),
load("res://Levels/GridTown/Buildings/Building3/3.tscn"),
load("res://Levels/GridTown/Buildings/Alley/alley.tscn"),
]

@export var sewer_scene:Node3D
var num_sewer_connections = 6
var sewer_entrances = []
var sewer_exits = []

func generate():
	tracks()
	terrain_mesh()
	building_layout()
	sewer()
	queue_free()

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
			tset(buildings, tile, PLOT)
			if block == intersection:
				tset(buildings, tile, STREET)
				intersection += randi_range(MIN_BLOCK_WIDTH, MAX_BLOCK_WIDTH)
			else:
				tset(buildings, tile, PLOT)
				if tile == station_tile or tile == station_tile - Vector2i(1,0) or tile == station_tile + Vector2i(1,0):
					place_station()
				else:
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

func place_station():
	var cell = station_tile * TILE_TO_METER_RATIO
	var station = load("res://Levels/GridTown/Buildings/Station/station.tscn").instantiate()
	station.position = Vector3(cell.x, get_height(station_tile), cell.y)
	level.add_child(station)

var station_tile
func tracks():
	var track = level.get_node("Tracks")
	track.global_position.x = WIDTH/2 * TILE_TO_METER_RATIO
	track.global_position.z = LENGTH * TILE_TO_METER_RATIO
	station_tile = Vector2i(round(WIDTH/2) + 1, LENGTH - 1)
	
	var sprite = Sprite3D.new()
	sprite.texture = load("res://icon.svg")
	sprite.position = Vector3(station_tile.x * TILE_TO_METER_RATIO, 30, station_tile.y * TILE_TO_METER_RATIO)
	level.add_child(sprite)

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

func get_height(_where:Vector2i):
	return 0

func sewer():
	level.add_child(load("res://Levels/GridTown/Sewer/Sewer.tscn").instantiate())
	sewer_exits.shuffle()
	sewer_entrances.shuffle()
	for i in num_sewer_connections:
		sewer_entrances[i].connect_exit(sewer_exits[i])
	for i in range(num_sewer_connections, sewer_entrances.size()):
		sewer_entrances[i].queue_free()
	for i in range(num_sewer_connections, sewer_exits.size()):
		sewer_exits[i].queue_free()

	return
	const NUM_ENTRANCES:int = 6
	var sewer_map = sewer_scene.tilemap
	var street_tiles = buildings.get_used_cells_by_id(0, Vector2i(STREET,0))
	var sewer_tunnels = sewer_map.get_used_cells_by_id(0, Vector2i(2,0))
	# get_used_cells_by_id(source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = -1) const
	var overlapping_tiles = Global.intersection(street_tiles,sewer_tunnels)
	var entrance_scene = load("res://Levels/GridTown/Sewer/Doors/Entrance/SewerEntrance.tscn")
	var exit_scene = load("res://Levels/GridTown/Sewer/Doors/Exit/SewerExit.tscn")
	for i in NUM_ENTRANCES:
		var tile = overlapping_tiles.pick_random()
		overlapping_tiles.erase(tile)
		
		var street_2d = buildings.map_to_local(tile)
		var street_pos = Vector3(street_2d.x + (TILE_TO_METER_RATIO / 2), 0, street_2d.y + (TILE_TO_METER_RATIO / 2))
		var sewer_2d = sewer_map.map_to_local(tile)
		var sewer_pos = Vector3(sewer_2d.x + (TILE_TO_METER_RATIO / 2), sewer_scene.global_position.y + 1, sewer_2d.y + (TILE_TO_METER_RATIO / 2))
		
		var entrance = entrance_scene.instantiate()
		var exit = exit_scene.instantiate()
		
		entrance.global_position = street_pos
		exit.global_position = sewer_pos
		
		entrance.exit = exit
		exit.entrance = entrance
		
		level.add_child(entrance)
		level.add_child(exit)

func _process(_delta: float) -> void:
	var player = Global.players.front()
	if not player:
		return
	var pos = player.global_position / TILE_TO_METER_RATIO
	var tile = Vector2(pos.x,pos.z) * 8
	$Sprite2D.position = tile
