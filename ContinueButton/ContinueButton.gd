extends Node3D

func _ready() -> void:
	SignalBus.out_of_level.connect(enable)
	SignalBus.preparing_for_level.connect(disable)

func enable():
	$InteractableArea.enable()

func disable():
	$InteractableArea.disable()

func _on_interactable_area_interacted(who: Variant) -> void:
	SignalBus.emit_signal("continue_button_pressed")
