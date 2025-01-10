extends Node3D

@export var debug:bool = false

@export var sight_distance:float = 10.0
var player_sightings:Dictionary = {}

signal updated

class PlayerSighting:
	var currently_seen:bool = false
	var last_seen_at:Vector3
	
	func _init(where) -> void:
		last_seen_at = where

func _ready() -> void:
	for player in Global.players:
		var sighting = PlayerSighting.new(player.global_position)
		player_sightings[player] = sighting

func update() -> void:
	sight_players()
	emit_signal("updated")

func get_seen_players() -> Array[Player]:
	var players:Array[Player] = []
	for player in player_sightings:
		var sighting = player_sightings[player]
		if sighting.currently_seen:
			players.append(player)
	return players

var last_seen_markers = []
func sight_players() -> void:
	if Global.players.size() != player_sightings.size():
		player_sightings.clear()
		for player in Global.players:
			var sighting = PlayerSighting.new(player.global_position)
			player_sightings[player] = sighting
		
	var raycast = $SightRayCast
	for player in Global.players:
		var player_sighting = player_sightings[player]
		var player_pos = player.global_position
		if global_position.distance_to(player_pos) > sight_distance:
			player_sighting.currently_seen = false
			continue
		raycast.target_position = to_local(player_pos)
		if raycast.get_collider() is not Player:
			player_sighting.currently_seen = false
			continue
		player_sighting.currently_seen = true
		player_sighting.last_seen_at = player_pos
	
	if debug:
		for player in player_sightings:
			var sighting = player_sightings[player]
			if sighting.currently_seen:
				print(get_parent(), " sees ", sighting.player.name, " at ", sighting.last_seen_at)
				sighting.player.get_node("CanvasLayer/seen?").text = "seen by " + get_parent().name
			else:
				sighting.player.get_node("CanvasLayer/seen?").text = ""
