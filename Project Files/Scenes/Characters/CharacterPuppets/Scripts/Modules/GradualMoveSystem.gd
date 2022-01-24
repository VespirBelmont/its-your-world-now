extends Node

onready var controller = get_parent().get_parent()

export (String, "Walk", "Run", "Sprint") var default_move_state_mod = "Walk" #This is what state mod will be used by default for the Move State

export var accelerations = {"Walk": 0.0, "Run": 0.0, "Sprint": 0.0} #Acceleration Presets 
export var decelerations = {"Walk": 0.0, "Run": 0.0, "Sprint": 0.0} #Decelerate Presets
var acceleration = 0.0 #How fast the character accelerates to the top speed
var deceleration = 0.0 #How fast the character slows down

export var speed_max = 0.0 #The top speed the character can move
export var decelerate_in_air = true #Determines if you can slow down/stop in the air

export (float, 0, 1) var air_control = 1 #How much control the character has in the air [0 = No control | 1 = Full Control] 
var velocity = Vector3() #This is the overall speed the character is moving at
var direction = Vector3() #This is the direction the character is moving

export (float) var gravity #The gravity amount that'll pull the character down
export (float) var gravity_fall_mod #The amount gravity is modified when falling [More in the Documentation Document]
export (float) var gravity_max = 5

var cam

var is_moving = false

func _ready():
	acceleration = accelerations[default_move_state_mod]
	deceleration = decelerations[default_move_state_mod]


#This handles applying gravity to the character
func apply_gravity(delta):
	#if effects.Quicksand: return
	
	var final_gravity = gravity #This will allow us to modify the value of gravity without changing it
	
	if (velocity.y > 0): #If the character is falling
		final_gravity += gravity_fall_mod #Gravity Fall modifier is added to the final gravity
	
	velocity.y += final_gravity * delta #Then we add the final gravity smoothed out with delta which will move the character down nicely
	
	if velocity.y >= gravity_max:
		velocity.y = gravity_max
	
	if velocity.y == -0: velocity.y = 0

func move():
	velocity = controller.move_and_slide(velocity, Vector3.UP)

#This handles increasing the character's velocity
func accelerate(_dir):
	if cam == null:
		cam = controller.cam
	
	match _dir:
		"Forward":
			if controller.is_on_floor():
				velocity += cam.get_parent().get_parent().transform.basis.x * acceleration
			else:
				velocity += cam.get_parent().get_parent().transform.basis.x * (acceleration * air_control)
		"Backward":
			if controller.is_on_floor():
				velocity += -cam.get_parent().get_parent().transform.basis.x * acceleration
			else:
				velocity += -cam.get_parent().get_parent().transform.basis.x * (acceleration * air_control)
		"Right":
			if controller.is_on_floor():
				velocity += cam.get_parent().get_parent().transform.basis.z * acceleration
			else:
				velocity += cam.get_parent().get_parent().transform.basis.z * (acceleration * air_control)
		"Left":
			if controller.is_on_floor():
				velocity += -cam.get_parent().get_parent().transform.basis.z * acceleration
			else:
				velocity += -cam.get_parent().get_parent().transform.basis.z * (acceleration * air_control)
	
	#Then clamp the velocity to make sure the character isn't going slower or faster than allowed
	velocity.x = clamp(velocity.x, -speed_max, speed_max)
	velocity.z = clamp(velocity.z, -speed_max, speed_max)
	
	if velocity.x == -0: velocity.x = 0
	if velocity.z == -0: velocity.z = 0
	
	if velocity.x != 0 or velocity.z != 0:
		is_moving = true


#This handles the decreasing of the character's velocity
func decelerate():
	if cam == null:
		cam = controller.cam
	
	velocity.x -= deceleration * direction.x #Decrease velocity by the deceleration speed in the direction they're moving
	velocity.x = clamp(velocity.x, -speed_max, speed_max) #Clamp to avoid unwanted speeds
	
	velocity.z -= deceleration * direction.z #Decrease velocity by the deceleration speed in the direction they're moving
	velocity.z = clamp(velocity.z, -speed_max, speed_max) #Clamp to avoid unwanted speeds
	
	#If the velocity is under a threshold then set it to 0; this makes movement feel better.
	if abs(velocity.x) <= 5: velocity.x = 0
	if abs(velocity.z) <= 5: velocity.z = 0
	
	if velocity.x == -0: velocity.x = 0
	if velocity.z == -0: velocity.z = 0
	
	if velocity.x == 0 and velocity.z == 0:
		is_moving = false


#func is_moving():
#	if abs(velocity.x) == 0:
#		if abs(velocity.z) == 0:
#			return false
#	
#	return true

func change_gravity(new_grav):
	gravity = new_grav

