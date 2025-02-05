extends Control

func init(player) -> void:
	$ProgressBar.max_value = player.MAX_HEALTH
	$ProgressBar.value = player.current_health
