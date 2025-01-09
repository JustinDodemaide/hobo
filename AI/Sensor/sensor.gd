extends Node

var sighted_players:Array = []

class PlayerSighting:
	var player:Player
	var last_seen_at:Vector3
	
	func _init(_player, where) -> void:
		player = _player
		last_seen_at = where

func update() -> void:
	sight_players()
	

func sight_players() -> void:
	var raycast = $SightRayCast
	for player in Global.players:
		raycast.target_position = player.global_position
		if raycast.get_collider() is not Player:
			continue
		var sighting = PlayerSighting.new(player, player.global_position)
		sighted_players.append(sighting)

func _on_update_timeout() -> void:
	update()
