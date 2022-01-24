extends "res://Scenes/Characters/CharacterPuppets/Scripts/Puppets/Charactercore3D.gd"


#This handles changing the state
func change_state(new_state):
	match new_state:
		"Idle":
#			if $Timers/IdleTalkTimer.time_left == 0:
#				$Timers/IdleTalkTimer.wait_time = rand_range(0.5, 15)
#				$Timers/IdleTalkTimer.start()
			match state_mod:
				"Standing":
					next_anim = "Idle"
				"Sitting":
					next_anim = "Sitting"
		
		"Move":
			match state_mod:
				"None":
					change_state_mod("Run")
				"Run":
					#move_speed = speed_presets.Run
					next_anim = "Run"
#					$Timers/StepTimer.wait_time = 0.4
				"Sprint":
					#move_speed = speed_presets.Sprint
					next_anim = "Sprint"
#					$Timers/StepTimer.wait_time = 0.2
			
			#play_step_sound()
#			if $Timers/StepTimer.time_left == 0:
#				$Timers/StepTimer.start()
		
		"Attack":
			next_anim = "Attack"
		
		"Jump":
			next_anim = "Jump"
		
		"Hurt":
			if state in ["Hurt", "Dead"] or $Timers/InvincibleDuration.time_left != 0:
				return
			
			$HurtDuration.start()
			emit_signal("toggle_health_ui", true)
			
			#if health_current <= 0:
				#change_state("Dead")
		
		"Dead":
			if state == "Dead": return
			#if not can_control: return
			
			#can_control = false
			next_anim = "Death"
			emit_signal("Dead")
	
	state = new_state


#This handles changing the state modifier [More in the Documentation Document]
func change_state_mod(new_mod):
	state_mod = new_mod #The state modifier is set to the new modifier
	change_state(state) #Then we apply changes by refreshing the state by changing the state to our current state


#This handles player inputs
func control_check():
	#These are variable shortcuts and combinations for Inputs
	#if not can_control: return
	if state in ["Dead", "Hurt", "Attack"]: return
	
	var move_forward = Input.is_action_pressed("Forward")
	var move_backward = Input.is_action_pressed("Backward")
	var move_right = Input.is_action_pressed("Right")
	var move_left = Input.is_action_pressed("Left")
	
	var jump_start = Input.is_action_just_pressed("Jump") and not jump_module.jump_started and jump_module.can_jump()
	var jump_continue = Input.is_action_pressed("Jump")
	var sprint = Input.is_action_pressed("Sprint") and is_on_floor()
	var joy_rot = Vector3(Input.get_joy_axis(0, JOY_AXIS_0), 0, Input.get_joy_axis(0, JOY_AXIS_1))
	
	var attack = Input.is_action_just_pressed("Attack") #and can_attack
	
	if "Instant" in move_module.name: #If it's instant movement
		move_module.velocity.x = 0
	
	if "Gradual" in move_module.name: #If the movement system is set to Instant movement
		#If the character is on the floor
		#Or if they're in the air and can slow down/stop in the air
		if is_on_floor() or not is_on_floor() and jump_module.decelerate_in_air:
			move_module.velocity.x = 0 #Set the horizontal movement to 0 to stop the character
	
	if move_right: #If the character is moving Right
		move_module.direction.x = 1 #We set the direction to 1 since we're moving Right [Positive]
		if "Instant" in move_module.name: #If it's instant movement
			if is_on_floor(): #We check to see if the character is on the floor
				move_module.velocity.x = move_module.move_speed #We set the character movement to the instant movement speed
			else: #If the character is in the air
				move_module.velocity.x = move_module.move_speed * move_module.air_control #We set their movement to the instant movement speed times the air control value
		if "Gradual" in move_module.name: #If it's the Gradual movement
			move_module.accelerate() #Then accelerate and the function will handle the rest
	
	if move_left: #If the character is moving Left
		move_module.direction.x = -1 #We set the direction to -1 since we're moving Left [Negative]
		
		if "Instant" in move_module.name: #If it's instant movement
			if is_on_floor(): #We check to see if the character is on the floor
				move_module.velocity.x = -move_module.move_speed #We set the character movement to the instant movement speed
			else: #If the character is in the air
				move_module.velocity.x = -move_module.move_speed * move_module.air_control #We set their movement to the instant movement speed times the air control value
		if "Gradual" in move_module.name: #If the movement system is set to Gradual movement
				move_module.accelerate() #Then accelerate and the function will handle the rest
	
	#If the player isn't moving
	if not move_right and not move_left:
		#If the movement system is set for Gradual and the state is still Move
		if "Gradual" in move_module.name and state == "Move":
			#If the player is on the floor
			#Or if the player is in the air and can decelerate in the air
			if is_on_floor() or not is_on_floor() and move_module.decelerate_In_Air:
				move_module.decelerate() #Then decelerate!
	
	
	if jump_start: #If the jump is being pressed and can launch
		jump_module.jump_launch() #Do the jump launch
	if jump_continue: #If the character is already jumping but had variable jump setup
		jump_module.jump_continue() #Continue the jump
	
	#If the jump has been started but the jump button isn't being pressed; then the variable jump is over
	if jump_module.jump_started and not is_on_floor() and not jump_continue:
		jump_module.jump_started = false #Set jump started to false
		
		if "Variable" in jump_module.name:
			jump_module.reset_duration() #Reset the jump duration
		jump_module.jump_count_left -= 1 #And take away a jump count since the jump has ended
	
	state_check() #Do a forced state check. This is used to make sure movement is interacting correctly with the stamina system.


#This handles making sure the player is in the right state
func state_check():
	if state == "Idle": #If the player is in the Idle state
		if move_module.velocity.x != 0: #If horizontal movement isn't 0
			change_state("Move") #Change the state to Move
			change_state_mod(move_module.default_move_state_mod) #And set the state modifier to the default move state modifier
	
	if state == "Move": #If the player is in the Move state
		if move_module.velocity.x == 0: #If horizontal movement is 0 [No longer moving]
			change_state("Idle") #Change the state to Idle
			change_state_mod("None") #And reset the state mode back to None
		else: #Otherwise if the horizontal movement isn't 0 [Still moving]
			use_particle("Dust") #Use the Dust particle
	
	#If the player isn't on the floor 
	#and the state isn't WallSlide
	if not is_on_floor():
		if state != "Fall": #If the state isn't fall
			if move_module.velocity.y > 0: #If the player is moving downward
				change_state("Fall") #Change the state to Fall
				change_state_mod("None") #And reset the state mode back to None
	
	#If the state is fall 
	#and the player is on the floor
	if state == "Fall" and is_on_floor():
		jump_module.landed() #Then the player has landed


func _physics_process(delta):
	move_module.apply_gravity(delta)
	control_check()
	
	var snap = Vector3.ZERO
	
	if state != "Jump":
		snap = Vector3.DOWN * 16
	
	move_module.velocity = move_and_slide_with_snap(move_module.velocity, snap, Vector3.UP)
	
	if global_transform.origin.y <= death_fall_height : 
		emit_signal("fell_off_world")
	state_check()
	
	$ModelController/Model.update_animation(next_anim)
	next_anim = ""

#func bounce(bounce_power):
	#velocity.y = bounce_power
	#move_and_slide(velocity, Vector3.UP)

func change_death_height(new_height):
	death_fall_height = new_height


func animation_over(anim_name):
	if anim_name == "Attack":
		change_state("Idle")

