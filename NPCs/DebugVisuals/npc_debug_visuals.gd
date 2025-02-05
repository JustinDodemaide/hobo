extends Node3D

var npc

func _ready() -> void:
	npc = get_parent()

func _process(_delta: float) -> void:
	if npc is CharacterBodyStateMachine or npc is StateMachine:
		$State.text = npc.state.name
