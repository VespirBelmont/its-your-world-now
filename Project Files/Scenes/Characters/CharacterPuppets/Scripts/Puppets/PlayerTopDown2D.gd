extends "res://CharacterPuppets/Scripts/Puppets/TopDownPuppet2D.gd"


func change_state(new_state):
	#Logic Brief:
	# > State is matched
	# > > State modifier is matched if applicable
	# > > > Behavior for that state is run
	
	match new_state: #It finds the new state being used
		"Idle":
			match state_mod: #It matches the state modifier to see if alternative behavior is to be used
				"None":
					next_anim = "Idle" #The next animation is set to the needed animation
		 
		"Move":
			match state_mod: #It matches the state modifier to see if alternative behavior is to be used
				"Walk":
					next_anim = "Walk"
				"Run":
					next_anim = "Run"
				"Sprint":
					next_anim = "Sprint"
		
		"Hurt":
			next_anim = "Hurt"
		
		"Dead":
			next_anim = "Dead"
			emit_signal("Dead")
			set_physics_process(false)
	
	state = new_state #Then at the end the state is set to the new state


#This handles changing the state modifier [More in the Documentation Document]
func change_state_mod(new_mod):
	state_mod = new_mod #The state modifier is set to the new modifier
	change_state(state) #Then we apply changes by refreshing the state by changing the state to our current state


#This handles any method/logic that needs to run each tick
func _physics_process(delta):
	control_check() #Then we check for control inputs
	
	move_module.velocity = move_and_slide(move_module.velocity, Vector2.UP).normalized() #The character is moved by their velocity
	state_check() #Then it checks to make sure it's in the right state
	
	update_animation() #The animation is updated
	update_direction() #And the direction is updated


#This handles player inputs
func control_check():
	#These are variable shortcuts and combinations for Inputs
	var move_right = Input.is_action_pressed("Right")
	var move_left = Input.is_action_pressed("Left")
	var move_up = Input.is_action_pressed("Up")
	var move_down = Input.is_action_pressed("Down")
	
	
	if "Instant" in move_module.name:
		move_module.velocity = Vector2()
	
	if move_up: #If the character is moving Right
		move_module.direction.y = -1 #We set the direction to 1 since we're moving Right [Positive]
		
		if "Instant" in move_module.name: #If it's instant movement
			move_module.velocity.y = -move_module.move_speed #We set the character movement to the instant movement speed
		if "Gradual" in move_module.name: #If it's the gradual movement
			accelerate("y") #Then accelerate and the function will handle the rest
	
	if move_down: #If the character is moving Right
		move_module.direction.y = 1 #We set the direction to 1 since we're moving Right [Positive]
		
		if "Instant" in move_module.name: #If it's instant movement
			move_module.velocity.y = move_module.move_speed #We set the character movement to the instant movement speed
		if "Gradual" in move_module.name: #If it's the gradual movement
			accelerate("y") #Then accelerate and the function will handle the rest
	
	if move_right: #If the character is moving Right
		move_module.direction.x = 1 #We set the direction to 1 since we're moving Right [Positive]
		
		if "Instant" in move_module.name: #If it's instant movement
			move_module.velocity.x = move_module.move_speed #We set the character movement to the instant movement speed
		if "Gradual" in move_module.name: #If it's the gradual movement
			accelerate("x") #Then accelerate and the function will handle the rest
	
	if move_left: #If the character is moving Left
		move_module.direction.x = -1 #We set the direction to -1 since we're moving Left [Negative]
		
		if "Instant" in move_module.name: #If it's instant movement
			move_module.velocity.x = -move_module.move_speed #We set the character movement to the instant movement speed
		if "Gradual" in move_module.name: #If it's the gradual movement
			accelerate("x") #Then accelerate and the function will handle the rest
	
	#If the player isn't moving
	if not move_right and not move_left:
		#If the movement system is set for Gradual and the state is still Move
		if "Gradual" in move_module.name and state == "Move":
			decelerate("x") #Then decelerate!
	
	if not move_up and not move_down:
		#If the movement system is set for Gradual and the state is still Move
		if "Gradual" in move_module.name and state == "Move":
			decelerate("y") #Then decelerate!
	
	state_check() #Do a forced state check. This is used to make sure movement is interacting correctly with the stamina system.


#This handles making sure the player is in the right state
func state_check():
	if state == "Idle": #If the player is in the Idle state
		if move_module.velocity != Vector2(0,0): #If horizontal movement isn't 0
			change_state("Move") #Change the state to Move
			change_state_mod(move_module.default_move_state_mod) #And set the state modifier to the default move state modifier
	
	if state == "Move": #If the player is in the Move state
		print(move_module.velocity)
		if move_module.velocity == Vector2(0,0): #If horizontal movement is 0 [No longer moving]
			change_state("Idle") #Change the state to Idle
			change_state_mod("None") #And reset the state mode back to None
		else: #Otherwise if the horizontal movement isn't 0 [Still moving]
			use_particle("Dust") #Use the Dust particle


