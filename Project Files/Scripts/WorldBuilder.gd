extends Node

#DEV NOTES [Vespir]
#The interface transitions are very crude and have 0 polish

onready var game_manager = get_parent() #This is the game manager aka the root of the entire game world
onready var cam_rig = get_parent().get_node("CamRig") #This gets the camera rig since we use it a bit

var active = false #Whether or not this menu system is active
var can_activate = false #Whether or not this menu system can be activated
var can_input = true #This is whether or not you can use an input

var menu_current = "" #The current menu being used

#Options Settings (Should be self-explanatory)
var option_min = 0
var option_max = 0
var option_current = 0


var land_spawn_pos = Vector3() #This is where land will spawn at
var character_spawn_pos = Vector3() #This is where characters will spawn at

var focused_land #This is the land we're focusing on
var focused_crossroad_anchor #This is the crossroad intersection point we're focusing on



func set_activation_status(_status):
	can_activate = _status

func _input(event):
	var toggle = Input.is_action_just_pressed("ToggleWorldBuilder") and can_input and can_activate
	
	if toggle:
		print("WorldBuilder.gd | Toggled by Input")
		print("WorldBuilder.gd | Can Input: ", can_input)
		print("WorldBuilder.gd | Can Activate: ", can_activate)
		toggle()

#This function handles opening and closing the World Builder menu
func toggle():
	update_shard_amounts() #Updates the WorldManager.gd to make sure the amount of shards is correct
	
	match active:
		true: #Menu is active
			active = false #Set to inactive since we don't want it running anything
			set_process(false) #Turn the process off since we won't be using it
			
			#Hide all the Interface
			$WorldBuilderMenu/CanvasLayer/BuilderUI.hide()
			$WorldBuilderMenu/Land.hide()
			$WorldBuilderMenu/Characters.hide()
			$WorldBuilderMenu/Selection.hide()
			
			#If there's a player (there won't be at the start)
			if game_manager.player_character != null:
				#Set the camera target to the player character
				cam_rig.set_new_target(game_manager.player_character)
			else: #If the game is just starting
				#Set the camera target to the default position node
				cam_rig.set_new_target(get_parent().get_node("CamDefaultPos"))
			
			get_parent().check_for_builder_cutscenes() #Check to see if there's any events triggered
			
			#If there's a player character then they can now move
			if game_manager.player_character != null:
				game_manager.player_character.set_can_move(true)
		
		false: #Menu isn't active
			#If there's a player character then they can't move now
			if game_manager.player_character != null:
				game_manager.player_character.set_can_move(false)
			
			active = true #Set the system to active
			
			cam_rig.set_new_target($WorldBuilderMenu) #Set the Builder Menu to the new camera target
			$WorldBuilderMenu/Selection.show() #Show the controls
			yield(get_tree().create_timer(4), "timeout") #Wait for everything to get ready
			set_process(true) #Set the process to true

#This function handles changing menus in the World Builder menu
func change_menu(_new_menu):
	option_current = 0 #We always reset the current option to 0 
	
	match _new_menu:
		"Land":
			$WorldBuilderMenu/Land.show() #This will display the lands available
			option_max = $WorldBuilderMenu/Land.get_child_count()-1 #This gets the shard count
			$WorldBuilderMenu/Land.get_child(option_current).show()
		
		"Character":
			$WorldBuilderMenu/Characters.show() #This will display the characters available
			option_max = $WorldBuilderMenu/Characters.get_child_count()-1 #This gets the shard count
		
		"Builder":
			$WorldBuilderMenu/CanvasLayer/BuilderUI.show() #This will display the Builder Interface
	
	menu_current = _new_menu #Sets the current menu to the new menu we're switching to
	set_process(true) #This sets the process to true

func _process(delta):
	if menu_current in ["Land", "Character"]:
		sphere_selection_controls()
	
	if menu_current == "Builder":
		builder_controls()

func sphere_selection_controls():
	if not active: return
	
	#Variable Control Shortcuts that make actions easier to define
	var prev_sphere = Input.is_action_just_pressed("Sphere_Prev")
	var next_sphere = Input.is_action_just_pressed("Sphere_Next")
	var select = Input.is_action_just_pressed("UI_Confirm")
	
	var last_selection = option_current #This is the last option used for more efficient code
	
	#This handles moving between spheres
	if prev_sphere:
		option_current -= 1
	if next_sphere:
		option_current += 1
	limit_options() #This makes sure that the current option isn't over the max or under the min
	
	#If the last option and the current option are different (meaning we moved to look at a new sphere)
	if option_current != last_selection:
		match menu_current: #Match the menu we're in since this function is used for both categories
			"Land":
				$WorldBuilderMenu/Land.get_child(last_selection).hide() #Hide the last land shown
				$WorldBuilderMenu/Land.get_child(option_current).show() #Show the current land
				
			
			"Character":
				$WorldBuilderMenu/Characters.get_child(last_selection).hide()
				$WorldBuilderMenu/Characters.get_child(option_current).show()
	
	if select:
		match menu_current:
			"Land":
				create_land()
			"Character":
				create_character()
		#set_process(false)

func builder_controls():
	#if not active: return
	
	var move_forward = Input.is_action_pressed("MoveForward")
	var move_backward = Input.is_action_pressed("MoveBackward")
	var move_right = Input.is_action_pressed("MoveRight")
	var move_left = Input.is_action_pressed("MoveLeft")
	var velocity = Vector3()
	var cam = get_parent().get_node("CamRig/YRot/ZRot/Cam")
	var move_speed = 0.07
	
	if move_forward:
		velocity = cam.get_parent().get_parent().transform.basis.x * move_speed
	if move_backward:
		velocity = -cam.get_parent().get_parent().transform.basis.x * move_speed
	if move_right:
		velocity = cam.get_parent().get_parent().transform.basis.z * move_speed
	if move_left:
		velocity = -cam.get_parent().get_parent().transform.basis.z * move_speed
	
	focused_land.global_transform.origin += velocity
	
	var raise_land = Input.is_action_pressed("RaiseLand")
	var lower_land = Input.is_action_pressed("LowerLand")
	var elevation_speed = 0.06
	
	if raise_land:
		focused_land.global_transform.origin.y += elevation_speed
	if lower_land:
		focused_land.global_transform.origin.y -= elevation_speed
	
	var rotate_clockwise = Input.is_action_pressed("RotateLandClockwise")
	var rotate_counter_clockwise = Input.is_action_pressed("RotateLandCounterClockwise")
	
	if rotate_clockwise:
		focused_land.rotation_degrees.y += .5
	if rotate_counter_clockwise:
		focused_land.rotation_degrees.y -= .5
	
	var connect = Input.is_action_pressed("UI_Confirm")
	
	if connect:
		var connected = focused_crossroad_anchor.get_parent().try_to_connect_land()
		if connected:
			var collisions = focused_crossroad_anchor.get_parent().get_node("CrossroadDetection").get_overlapping_areas()
			
			for col in collisions:
				if col != focused_crossroad_anchor.get_parent().get_node("CrossroadDetection"):
					col.get_parent().try_to_connect_land()
			
			focused_crossroad_anchor.get_parent().toggle_orbs() #This will toggle the anchor orbs off
			toggle() #Once land is created toggle the menu off

func limit_options():
	if option_current > option_max:
		option_current = option_min
	
	if option_current < option_min:
		option_current = option_max

func input_cooldown():
	can_input = false
	yield(get_tree().create_timer(0.01), "timeout")
	can_input = true

func create_land():
	Settings.land_built += 1
	var new_land = $WorldBuilderMenu/Land.get_child(option_current).sphere_content.instance()
	$LandChunks.add_child(new_land)
	new_land.global_transform.origin = land_spawn_pos
	$WorldBuilderMenu/Land.get_child(option_current).used()
	
	focused_land = new_land
	focused_land.show_orbs()
	
	if Settings.land_built > 1:
		cam_rig.set_new_target(focused_crossroad_anchor) #Set the new camera target to the crossroad anchor point
		change_menu("Builder")
		focused_crossroad_anchor.get_parent().toggle_orbs()
	else:
		focused_land.solidify()
		toggle()

func create_character():
	Settings.characters_built += 1
	
	var new_character = $WorldBuilderMenu/Characters.get_child(option_current).sphere_content.instance()
	$CharacterList.add_child(new_character)
	new_character.global_transform.origin = focused_land.get_spawn_point()
	$WorldBuilderMenu/Characters.get_child(option_current).used()
	
	if game_manager.player_character == null and new_character.is_in_group("Player"):
		game_manager.player_character = new_character
		
		new_character.cam = game_manager.get_node("CamRig/YRot/ZRot/Cam")
	
	toggle()

func update_land_info(_new_pos, _crossroad_anchor):
	land_spawn_pos = _new_pos
	focused_crossroad_anchor = _crossroad_anchor

func update_shard_amounts():
	WorldManager.lands_shards_owned = $WorldBuilderMenu/Land.get_child_count()
	WorldManager.charcter_shards_owned = $WorldBuilderMenu/Characters.get_child_count()
