extends Node3D

enum DIMENSIONS{ONExONE, TWOxONE, TWOxTWO}
const one_by_one_buildings = []
const two_by_one_buildings = ["res://store.glb"]

var spaces = [null, null,
			  null, null]

func init(highest,lowest):
	# We don't want the foundation to be floating, so we make sure its tall
	# enough to go into the ground, even if its at the highest point of the
	# terrain
	var difference =  highest - lowest
	$MeshInstance3D.mesh.size.y = difference
	$MeshInstance3D.position.y -= difference / 2

func _ready() -> void:
	place_buildings()

func place_buildings():
	# figure out which sizes can be placed
	while true:
		var possibilities = []
		if not spaces[0] and not spaces[1] and not spaces[2] and not spaces[3]:
			possibilities.append(BuildingPossibility.new(DIMENSIONS.TWOxTWO, []))
		
		if not spaces[0] and not spaces[1]:
			possibilities.append(BuildingPossibility.new(DIMENSIONS.TWOxONE, [0,1]))
		if not spaces[2] and not spaces[3]:
			possibilities.append(BuildingPossibility.new(DIMENSIONS.TWOxONE, [2,3]))
		if not spaces[0] and not spaces[2]:
			possibilities.append(BuildingPossibility.new(DIMENSIONS.TWOxONE, [0,2]))
		if not spaces[1] and not spaces[3]:
			possibilities.append(BuildingPossibility.new(DIMENSIONS.TWOxONE, [1,3]))
		
		# manual loop unrolling
		if not spaces[0]:
			possibilities.append(BuildingPossibility.new(DIMENSIONS.ONExONE, [0]))
		if not spaces[1]:
			possibilities.append(BuildingPossibility.new(DIMENSIONS.ONExONE, [1]))
		if not spaces[2]:
			possibilities.append(BuildingPossibility.new(DIMENSIONS.ONExONE, [2]))
		if not spaces[3]:
			possibilities.append(BuildingPossibility.new(DIMENSIONS.ONExONE, [3]))
		
		if possibilities.is_empty():
			break
		place_building(possibilities.pick_random())
		possibilities.clear() # not sure if this is needed

func place_building(specs:BuildingPossibility) -> void:
	var building
	if specs.dimension == DIMENSIONS.ONExONE:
		building = one_by_one_buildings.pick_random()
	if specs.dimension == DIMENSIONS.TWOxONE:
		building = two_by_one_buildings.pick_random()
		building = load(building).instantiate()
		building.position = twoxone_pos[specs.spot]
		building.rotation = twoxone_rot[specs.spot]
	for i in specs.spot:
		spaces[i] = building
	add_child(building)

var twoxone_pos = {
	[0,1]:Vector3(-5,2.5,-0.25),
	[2,3]:Vector3(0,2.5,-0.25),

	[0,2]:Vector3(0,2.5,0.75),
	[1,3]:Vector3(0,2.5,5.75),
}

var twoxone_rot = {
	[0,2]:Vector3(0,0,0),
	[1,3]:Vector3(0,0,0),
	[2,3]:Vector3(0,90,0),
	[0,1]:Vector3(0,90,0),
}

class BuildingPossibility:
	var dimension
	var spot
	func _init(dimension:DIMENSIONS, spot:Array):
		self.dimension = dimension
		self.spot = spot


signal player_entered_restricted_area(area:Area3D,player:Player)
func _on_restricted_area_area_entered(area: Area3D) -> void:
	var parent = area.get_parent()
	if parent is Player:
		emit_signal("player_entered_restricted_area", area, parent)

signal player_exited_restricted_area(area:Area3D,player:Player)
func _on_restricted_area_area_exited(area: Area3D) -> void:
	var parent = area.get_parent()
	if parent is Player:
		emit_signal("player_exited_restricted_area", area, parent)
