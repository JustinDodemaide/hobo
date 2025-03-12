extends Label

func _ready() -> void:
	SignalBus.new_level_challenged_assigned.connect(update)

func update():
	text = Global.scene_handler.current_level_challenge.description
