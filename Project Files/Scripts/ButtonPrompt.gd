extends Spatial

signal Button_Pressed

signal Activate
signal Deactivate

export var enabled = true

export (String, "Sphere_Prev", "Sphere_Next", "UI_Confirm", "ToggleWorldBuilder") var used_input

export (AudioStream) var pressed_sound
export (float) var pressed_volume

export (float) var input_cooldown = 0.2

var can_input = true

var activated = false


func _ready():
	update_input_visuals()
	
	if enabled:
		enable()
	else:
		disable()
	
	if pressed_sound == null: return
	
	$PressedAudio.stream = pressed_sound
	$PressedAudio.volume_db = pressed_volume

func update_input_visuals():
	var keyboard_key
	var joypad_button
	
	var input_list = InputMap.get_action_list(used_input)
	for input in input_list:
		if input is InputEventKey:
			keyboard_key = translate_key(input.scancode)
		if input is InputEventJoypadButton:
			joypad_button = translate_button(input.button_index)
	
	$PromptManager.setup(keyboard_key, joypad_button)

func translate_key(_key):
	match _key:
		32:
			return "Space"
		16777221:
			return "Enter"
		16777217:
			return "Escape"
		16777218:
			return "Tab"
		16777220:
			return "Backspace"
		
		65:
			return"A"
		67:
			return "C"
		68:
			return "D"
		83:
			return "S"
		88:
			return "X"
		90:
			return "Z"
		
		16777231:
			return "Arrow Left"
		16777232:
			return "Arrow Up"
		16777233:
			return "Arrow Right"
		16777234:
			return "Arrow Down"
	
	print("ButtonPrompt.gd")
	print("{")
	print("ButtonPrompt.gd ALERT")
	print("Scancode Not Found: ", _key)
	print("}")

func translate_button(_button):
	match _button:
		3:
			return "North"
		2:
			return "West"
		1:
			return "East"
		0:
			return "South"
		
		10:
			return "Select"
		11:
			return "Options"
		
		12:
			return "DPad Up"
		13:
			return "DPad Down"
		14:
			return "DPad Left"
		15:
			return "DPad Right"
	
	print("ButtonPrompt.gd")
	print("{")
	print("ButtonPrompt.gd ALERT")
	print("Button Index Not Found: ", _button)
	print("}")

func _input(event):
	if Engine.editor_hint or not enabled or not can_input: return
	
	can_input = false
	
	if used_input == "":
		return
	
	var button_pressed = Input.is_action_just_pressed(used_input) and Settings.current_device == "Keyboard" or \
		Input.is_action_just_pressed(used_input) and Settings.current_device == "Controller"
	
	if button_pressed:
		if activated:
			activated = false
			emit_signal("Deactivate")
		else:
			activated = true
			emit_signal("Activate")
		emit_signal("Button_Pressed")
	
	if input_cooldown > 0:
		yield(get_tree().create_timer(input_cooldown), "timeout")
	can_input = true

func toggle_label(label_1, label_2):
	var label = $OptionLabel.text
	
	if label == label_1:
		$OptionLabel.text = label_2
		return
	else:
		$OptionLabel.text = label_1

func disable():
	enabled = false

func enable():
	enabled = true

