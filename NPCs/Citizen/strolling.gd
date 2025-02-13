extends State

var destination:Marker3D

func enter(_previous_state: String, _data := {}) -> void:
	get_parent().move_to(destination.global_position)

func target_reached():
	get_parent().emit_signal("destination_reached")
	get_parent().queue_free()
