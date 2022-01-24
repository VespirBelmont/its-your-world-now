extends Spatial

func _ready():
	Settings.connect("Update_Prompts", self, "update_prompts")

func setup(_key, _button):
	if _key != null:
		$Keyboard/Anim.play(_key)

func update_prompts():
	var prompt = Settings.current_device
	var preference = Settings.controller_preference
	
	for main_prompt in get_children():
		if not "Anim" in main_prompt.name:
			if main_prompt.name != prompt:
				main_prompt.hide()
			else:
				main_prompt.show()
				
				if main_prompt.name == "Controller":
					for sub_prompt in main_prompt.get_children():
						if sub_prompt.name != preference:
							sub_prompt.hide()
						else:
							sub_prompt.show()

func button_pressed():
	$Anim.play("Press")

