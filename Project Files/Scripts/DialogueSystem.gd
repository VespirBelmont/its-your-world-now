extends Control

signal Finished
signal EndDialogue

export (float) var type_writer_speed = 0.2
var text = ""

var writing_finished = false

func open_dialogue():
	print("Open")
	$Anim.play("Toggle")
	yield($Anim, "animation_finished")
	emit_signal("Finished")

func close_dialogue():
	$Anim.play_backwards("Toggle")
	yield($Anim, "animation_finished")
	emit_signal("Finished")

func run_dialogue(_text = "No Text Available", _typewriter_speed = type_writer_speed, _text_size = 29):
	$Text/Label.visible_characters = 0
	$Text/Label.text = _text
	$Text/Label.get_font("font").set("size", _text_size)
	type_writer_speed = _typewriter_speed
	
	for letter in _text:
		$Text/Label.visible_characters += 1
		yield(get_tree().create_timer(type_writer_speed), "timeout")
	writing_finished = true
	
	if Settings.auto_continue_dialogue:
		yield(get_tree().create_timer(0.25), "timeout")
		end_dialogue()

func _input(event):
	var _continue = Input.is_action_just_pressed("DialogueContinue") and writing_finished
	
	if _continue:
		end_dialogue()

func end_dialogue():
	writing_finished = false
	
	$SubAnim.play("Clear Text")
	yield($SubAnim, "animation_finished")
	
	emit_signal("EndDialogue")
	

