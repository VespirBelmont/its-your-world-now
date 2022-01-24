extends Node

var player_character #This is the character node the player is using

#On load up of this node
func _ready():
	#Check to see if the player has played the game before
	
	if Settings.new_player: #If they haven't played before
		$Cutscenes/Intro.turn_on() #Turn on the Intro event
		$Cutscenes/Intro.run_next_action() #Start it off!
	
	else: #If they have played the game before
		$WorldBuilder.set_activation_status(true) #Set the World Builder to can be activated
		$WorldBuilder.change_menu("Land") #Set the World Builder Menu to Land
		$WorldBuilder.toggle() #Finally open the World Builder Menu

#THis checks for events that are specifically triggered from building lands
func check_for_builder_cutscenes():
	if Settings.characters_built == 0:
		if Settings.play_tutorial:
			$Cutscenes/CreateFirstLand.turn_on()
			$Cutscenes/CreateFirstLand.run_next_action()
		else:
			$WorldBuilder.set_activation_status(true)
			$WorldBuilder.change_menu("Character")
			$WorldBuilder.toggle()

