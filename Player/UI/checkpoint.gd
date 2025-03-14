extends Label

func _ready() -> void:
	SignalBus.new_checkpoint_assigned.connect(update)

func update(_item=null):
	pass

func _process(delta: float) -> void:
	return
	text = Global.scene_handler.checkpoint.description()
	text += ": " + str(Global.scene_handler.distance_to_checkpoint) + " stops left"
