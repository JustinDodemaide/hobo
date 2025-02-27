extends CanvasLayer

@onready var label = $PanelContainer/VBoxContainer/Label
const PREFIX = "Required Sustenance: "

func set_text(required_sustenance):
	$PanelContainer/VBoxContainer/Label.text = PREFIX + str(required_sustenance)

func _on_button_pressed() -> void:
	Global.scene_handler.transition("Level")

func lose():
	pass
