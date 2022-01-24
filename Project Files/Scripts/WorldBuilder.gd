extends Node

var active = false
var can_activate = false
var menu_current = ""

var option_min = 0
var option_max = 0
var option_current = 0

var can_input = true

var land_spawn_pos = Vector3()
var character_spawn_pos = Vector3()

onready var game_manager = get_parent()
onready var cam_rig = get_parent().get_node("CamRig")

var focused_land 
var focused_crossroad

func set_activation_status(_status):
	can_activate = _status

func _input(event):
	var toggle = Input.is_action_just_pressed("ToggleWorldBuilder") and can_input and can_activate
	
	if toggle:
		toggle()

func toggle():
	match active:
		true: #Menu is up
			print("Turn Off Builder")
			$WorldBuilderMenu/CanvasLayer/BuilderUI.hide()
			active = false
			$WorldBuilderMenu/Land.hide()
			$WorldBuilderMenu/Characters.hide()
			$WorldBuilderMenu/Selection.hide()
			if game_manager.player_character != null:
				cam_rig.set_new_target(game_manager.player_character)
			else:
				cam_rig.set_new_target(get_parent().get_node("CamDefaultPos"))
			set_process(false)
			get_parent().check_for_builder_cutscenes()
			if game_manager.player_character != null:
				game_manager.player_character.set_can_move(true)
		
		false: #Menu is down
			print("Turn On Builder")
			if game_manager.player_character != null:
				game_manager.player_character.set_can_move(false)
			
			active = true
			cam_rig.set_new_target($WorldBuilderMenu)
			$WorldBuilderMenu/Selection.show()
			yield(get_tree().create_timer(4), "timeout")
			set_process(true)

func change_menu(_new_menu):
	option_current = 0
	
	match _new_menu:
		"Land":
			$WorldBuilderMenu/Land.show()
			option_max = $WorldBuilderMenu/Land.get_child_count()-1
			
			if option_max <= -1:
				toggle()
		
		"Character":
			$WorldBuilderMenu/Characters.show()
			option_max = $WorldBuilderMenu/Characters.get_child_count()-1
		
		"Builder":
			set_process(true)
			$WorldBuilderMenu/CanvasLayer/BuilderUI.show()
	
	menu_current = _new_menu

func _process(delta):
	if menu_current in ["Land", "Character"]:
		sphere_selection_controls()
	
	if menu_current == "Builder":
		builder_controls()

func sphere_selection_controls():
	if not active: return
	
	var prev_sphere = Input.is_action_just_pressed("Sphere_Prev")
	var next_sphere = Input.is_action_just_pressed("Sphere_Next")
	var select = Input.is_action_just_pressed("UI_Confirm")
	
	var last_selection = option_current
	
	if prev_sphere:
		option_current -= 1
	if next_sphere:
		option_current += 1
	
	limit_options()
	
	if option_current != last_selection:
		match menu_current:
			"Land":
				$WorldBuilderMenu/Land.get_child(last_selection).hide()
				$WorldBuilderMenu/Land.get_child(option_current).show()
				
			
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
		var connected = focused_crossroad.get_parent().try_to_connect_land()
		if connected:
			var collisions = focused_crossroad.get_parent().get_node("CrossroadDetection").get_overlapping_areas()
			
			for col in collisions:
				if col != focused_crossroad.get_parent().get_node("CrossroadDetection"):
					col.get_parent().try_to_connect_land()
			
			print("Connected Lands")
			toggle()

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
		cam_rig.set_new_target(focused_crossroad)
		change_menu("Builder")
		focused_crossroad.get_parent().toggle_orbs()
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

func update_land_pos(_new_pos, _crossroad):
	land_spawn_pos = _new_pos
	focused_crossroad = _crossroad


