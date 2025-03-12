extends Label

func _ready() -> void:
	SignalBus.new_checkpoint_assigned.connect(update)

func update():
	text = Global.scene_handler.upcoming_checkpoint.description
	text += ": " + str(Global.scene_handler.distance_to_checkpoint) + " stops left"
