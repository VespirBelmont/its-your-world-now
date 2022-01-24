extends "res://CharacterPuppets/Scripts/Puppets/CharacterCore2D.gd"


#This handles increasing the character's velocity
func accelerate(axis):
	if is_on_floor(): #If they're on the floor we can just accelerate by accelerate times the direction the character is moving in
		move_module.velocity[axis] += move_module.acceleration * move_module.direction[axis]
	else: #If they're not on the floor we need to factor in air control
		move_module.velocity[axis] += (move_module.acceleration * move_module.direction[axis]) * move_module.air_control
	
	#Then clamp the velocity to make sure the character isn't going slower or faster than allowed
	move_module.velocity[axis] = clamp(move_module.velocity[axis], -move_module.speed_max, move_module.speed_max)


#This handles the decreasing of the character's velocity
func decelerate(axis):
	move_module.velocity[axis] -= move_module.deceleration * move_module.direction[axis] #Decrease velocity by the deceleration speed in the direction they're moving
	move_module.velocity[axis] = clamp(move_module.velocity[axis], -move_module.speed_max, move_module.speed_max) #Clamp to avoid unwanted speeds
	
	#If the velocity is under a threshold then set it to 0; this makes movement feel better.
	if abs(move_module.velocity[axis]) <= 5: move_module.velocity[axis] = 0


#This handles changing the direction of the character
func update_direction():
	if move_module.direction.x == 1: #If the character is moving right
		$DirectionAnim.play("Right") #Play the right animation
	elif move_module.direction.x == -1: #If the character is moving left
		$DirectionAnim.play("Left") #Play the left animation



