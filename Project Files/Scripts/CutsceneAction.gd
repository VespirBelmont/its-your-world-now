extends Node

signal SurpriseLink
signal Done

export (String, "Dialogue", "Audio Play", "Emit Signal", "Timer") var action_type = "Dialogue"

export (NodePath) var node_path
var node

#Dialogue Options
export (String) var dialogue_text
export (float) var typewriter_speed = 0.1
export (float) var text_size = 29

#Timer Options
export (float) var time_duration = 1

export (bool) var wait_for_finish = false

var ran = false

func _ready():
	if node_path != null or node_path != "":
		node = get_node(node_path)


func run():
	if ran == true: return
	ran = true
	
	match action_type:
		"Dialogue":
			node.run_dialogue(dialogue_text, typewriter_speed, text_size)
			node.connect("EndDialogue", self, "complete")
		
		"Audio Play":
			node.play()
			if wait_for_finish:
				yield(node, "finished")
			complete()
		
		"Emit Signal":
			print("CutsceneAction.gd | Signal Emitted from ", self.name)
			emit_signal("SurpriseLink")
			complete()
		
		"Timer":
			yield(get_tree().create_timer(time_duration), "timeout")
			complete()

func complete():
	emit_signal("Done")
	
	if action_type == "Dialogue":
		node.disconnect("EndDialogue", self, "complete")
