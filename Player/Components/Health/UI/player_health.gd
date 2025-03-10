extends Control

func init(health_component) -> void:
	return
	$ProgressBar.max_value = health_component.MAX_HEALTH
	$ProgressBar.value = health_component.current_health
