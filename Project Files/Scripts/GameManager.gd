extends Node

var player_character

func _ready():
	if Settings.new_player:
		$Cutscenes/Intro.turn_on()
		$Cutscenes/Intro.run_next_action()
	else:
		$WorldBuilder.set_activation_status(true)
		$WorldBuilder.change_menu("Land")
		$WorldBuilder.toggle()

func check_for_builder_cutscenes():
	if Settings.characters_built == 0:
		if Settings.play_tutorial:
			$Cutscenes/CreateFirstLand.turn_on()
			$Cutscenes/CreateFirstLand.run_next_action()
		else:
			$WorldBuilder.set_activation_status(true)
			$WorldBuilder.change_menu("Character")
			$WorldBuilder.toggle()

