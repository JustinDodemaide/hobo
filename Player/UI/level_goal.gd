extends Label

func _ready() -> void:
	SignalBus.new_level_challenged_assigned.connect(update)

func update(_item=null):
	return
	text = Global.scene_handler.challenge.description()

func _process(delta: float) -> void:
	text = Global.scene_handler.challenge.description()
