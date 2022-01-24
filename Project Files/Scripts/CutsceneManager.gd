extends Node

signal CutsceneOver

export var action_index = 0

var active = false

func turn_on():
	active = true

func run_next_action():
	if not active: return
	
	action_index += 1
	if action_index <= $Actions.get_child_count()-1:
		$Actions.get_child(action_index).run()
	else:
		emit_signal("CutsceneOver")
		active = false


