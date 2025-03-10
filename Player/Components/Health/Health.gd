extends Node

@export var player:Player

const MAX_HEALTH:int = 100
var current_health:int = MAX_HEALTH

func _ready() -> void:
	await player.ready
	await player.ui.ready
	await player.ui.health_ui.ready
	player.ui.health_ui.init(self)

func _on_player_ready() -> void:
	player.ui.health_ui.init(self)
