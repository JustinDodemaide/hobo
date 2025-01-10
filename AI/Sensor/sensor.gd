extends Node3D

@export var debug:bool = false

@export var sight_distance:float = 10.0
var player_sightings:Array = []

signal updated

class PlayerSighting:
	var player:Player
	var currently_seen:bool = false
	var last_seen_at:Vector3
	
	func _init(_player, where) -> void:
		player = _player
		last_seen_at = where

func _ready() -> void:
	for player in Global.players:
		var sighting = PlayerSighting.new(player, player.global_position)
		player_sightings.append(sighting)

func update() -> void:
	sight_players()
	emit_signal("updated")

func get_seen_players() -> Array[Player]:
	var players:Array[Player] = []
	for sighting in player_sightings:
		if sighting.currently_seen:
			players.append(sighting.player)
	return players

var last_seen_markers = []
func sight_players() -> void:
	if Global.players.size() != player_sightings.size():
		player_sightings.clear()
		for player in Global.players:
			var sighting = PlayerSighting.new(player, player.global_position)
			player_sightings.append(sighting)
		
	var raycast = $SightRayCast
	for i in Global.players.size():
		var player_sighting = player_sightings[i]
		var player_pos = player_sighting.player.global_position
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
		for sighting in player_sightings:
			if sighting.currently_seen:
				print(get_parent(), " sees ", sighting.player.name, " at ", sighting.last_seen_at)
				sighting.player.get_node("CanvasLayer/seen?").text = "seen by " + get_parent().name
			else:
				sighting.player.get_node("CanvasLayer/seen?").text = ""
