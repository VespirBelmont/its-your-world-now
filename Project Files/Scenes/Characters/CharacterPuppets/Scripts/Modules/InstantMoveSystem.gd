extends Node

onready var controller = get_parent().get_parent()
var wall_slide_module

export (String, "Walk", "Run", "Sprint") var default_move_state_mod = "Walk" #This is what state mod will be used by default for the Move State

export var move_speeds = { #Move speeds if the character is using instant movement
							  "Walk": 0.0,
							  "Run": 0.0,
							  "Sprint": 0.0,
								}

var move_speed = 0.0
export (float, 0, 1) var air_control = 1 #How much control the character has in the air [0 = No control | 1 = Full Control] 
var velocity = Vector2() #This is the overall speed the character is moving at
var direction = Vector2() #This is the direction the character is moving

export (float) var gravity #The gravity amount that'll pull the character down
export (float) var gravity_fall_mod #The amount gravity is modified when falling [More in the Documentation Document]



func _ready():
	move_speed = move_speeds[default_move_state_mod]
	for module in controller.get_node("Modules").get_children():
		if "WallSlide" in module.name:
			wall_slide_module = module


#This handles applying gravity to the character
func apply_gravity(delta):
	var final_gravity = gravity #This will allow us to modify the value of gravity without changing it
	
	if (velocity.y > 0): #If the character is falling
		final_gravity += gravity_fall_mod #Gravity Fall modifier is added to the final gravity
	
	if controller.state == "WallSlide": #If the character is wall sliding
		velocity.y = 0 #Velocity's Y value is set to 0 so only the slide gravity is moving the character
		final_gravity = wall_slide_module.slide_gravity #Then we set final gravity to the Slide gravity
	
	velocity.y += final_gravity * delta #Then we add the final gravity smoothed out with delta which will move the character down nicely


#This handles changing the direction of the character
func update_direction():
	if direction.x == 1: #If the character is moving right
		controller.get_node("DirectionAnim").play("Right") #Play the right animation
	elif direction.x == -1: #If the character is moving left
		controller.get_node("DirectionAnim").play("Left") #Play the left animation

