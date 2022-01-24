extends "res://Scenes/Characters/CharacterPuppets/Scripts/Puppets/CharacterCore3D.gd"

var cam
var can_move = true

func set_can_move(_state):
	can_move = _state

func set_state(_new_state):
	match _new_state:
		"Idle":
			$SpriteRig.next_anim = "Idle"
			$Particles/MovementCloud.emitting = false
		
		"Move":
			$Particles/MovementCloud.emitting = true
		
		"Jump":
			$Particles/MovementCloud.emitting = false
		
		"Hurt":
			pass
		
		"Dead":
			pass
	
	state = _new_state

func _physics_process(delta):
	move_module.apply_gravity(delta)
	control_check(delta)
	move_module.move()
	update_shadow()
	
	if global_transform.origin.y <= out_of_bounds_y + last_land.y:
		print("Out of bounds!: ", global_transform.origin)
		global_transform.origin = Vector3(0, 5, 0)
	
	if cam != null:
		look_at(cam.global_transform.origin, Vector3.UP)
	state_check()
	$SpriteRig.play_anim()

#This handles player inputs
func control_check(delta):
	if not can_move: return
	#These are variable shortcuts and combinations for Inputs
	#if not can_control: return
	if state in ["Dead", "Hurt", "Attack"]: return
	
	var move_forward = Input.is_action_pressed("MoveForward")
	var move_backward = Input.is_action_pressed("MoveBackward")
	var move_right = Input.is_action_pressed("MoveRight")
	var move_left = Input.is_action_pressed("MoveLeft")
	
	var jump_start = Input.is_action_just_pressed("Jump") and not jump_module.jump_started and jump_module.can_jump()
	var jump_continue = Input.is_action_pressed("Jump") and jump_module.jump_started
	#var sprint = Input.is_action_pressed("Sprint") and is_on_floor()
	var joy_rot = Vector3(Input.get_joy_axis(0, JOY_AXIS_0), 0, Input.get_joy_axis(0, JOY_AXIS_1))
	
	
	if is_on_floor() or not is_on_floor() and jump_module.decelerate_in_air:
		move_module.velocity.x = 0 #Set the horizontal movement to 0 to stop the character
	
	move_module.decelerate()
	
	var original_y = move_module.velocity.y
	move_module.direction = Vector3()
	var last_move_dir = ""
	
	if move_forward:
		move_module.direction.z = 1
		move_module.accelerate("Forward")
		last_move_dir = "Forward"
	if move_backward:
		move_module.direction.z = -1
		move_module.accelerate("Backward")
		last_move_dir = "Backward"
	if move_right: #If the character is moving Right
		move_module.direction.x = 1
		move_module.accelerate("Right") #Then accelerate and the function will handle the rest
		last_move_dir = "Right"
	if move_left:
		move_module.direction.x = -1
		move_module.accelerate("Left")
		last_move_dir = "Left"
	
	match last_move_dir:
		"Forward":
			$SpriteRig.next_anim = "WalkForward"
		"Backward":
			$SpriteRig.next_anim = "WalkBackward"
		"Right":
			$SpriteRig.next_anim = "WalkRight"
		"Left":
			$SpriteRig.next_anim = "WalkLeft"
	
	if last_move_dir == "":
		if state == "Move":
			if is_on_floor():
				set_state("Idle")
	
	move_module.velocity.y = original_y
	
	if jump_start: #If the jump is being pressed and can launch
		jump_module.jump_launch(delta) #Do the jump launch
		$Sounds/Jump.play()
		set_state("Jump")
	
	if jump_continue: #If the character is already jumping but had variable jump setup
		jump_module.jump_continue(delta) #Continue the jump
	
	#If the jump has been started but the jump button isn't being pressed; then the variable jump is over
	if jump_module.jump_started and not is_on_floor() and not jump_continue:
		jump_module.jump_started = false #Set jump started to false
		
		jump_module.reset_duration() #Reset the jump duration
		jump_module.jump_count_left -= 1 #And take away a jump count since the jump has ended


func state_check():
	if state == "Idle":
		if move_module.is_moving:
			set_state("Move")
	
	if state == "Move":
		if not move_module.is_moving:
			set_state("Idle")
	
	if state == "Jump":
		if is_on_floor():
			set_state("Idle")
			jump_module.landed()
	
	if state == "Move":
		if not $Sounds/WalkSound.playing:
			$Sounds/WalkSound.play()
	else:
		$Sounds/WalkSound.stop()


