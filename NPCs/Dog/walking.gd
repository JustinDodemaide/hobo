extends State

@onready var parent = $".."
var previous_state:String = ""
var character_speed:float = 5.0

var tracking_target:Variant = null

func physics_update(_delta: float) -> void:
	if tracking_target:
		parent.nav.set_target_position(tracking_target.global_position)
	
	if not parent.is_on_floor():
		parent.velocity += parent.get_gravity() * _delta
		parent.move_and_slide()
	if parent.nav.is_navigation_finished():
			return
	var next_path_position: Vector3 = parent.nav.get_next_path_position()
	parent.velocity = (next_path_position - parent.global_position).normalized() * character_speed
	# parent.look_at(next_path_position)
	parent.move_and_slide()

func enter(previous_state: String, data := {}) -> void:
	self.previous_state = previous_state
	if data.has("track"):
		tracking_target = data.track
	else:
		parent.nav.set_target_position(data.pos)
	parent.sprite.play("walk")

func exit() -> void:
	parent.sprite.play("idle")

func target_reached() -> void:
	match previous_state:
		"Wandering": parent.transition("Wandering")
		_: transition("Wandering")
