extends Node2D

onready var controller = get_parent().get_parent()
onready var move_module = controller.move_module


export (float) var slide_gravity = 0.0 #This is how the gravity effects the character while wall sliding
export var duration = { #These are the duration of slides before they're cancelled [Ignore if not using]
				"Wait": 0.0, #This is the wait time before the wall slide is over [Leave at 0 for endless sliding]
				"Timer": null, #This is the timer object we'll generate later
				}

export var slide_count = { #These are the slide count settings [-1 Means not using]
					"Max": -1, #This is the max amount of slides
					"Current": 0, #This is how many slides the character has left
					}
#This determines if the character has to keep moving into the wall to slide or if they can let go of buttons and slide
export (bool) var move_to_slide = true
export (bool) var reset_jumps = true #This determines if wall sliding resets the jump count

export (float) var wall_jump_force = 0.0 #This is how much the character will move up for a wall jump
export (float) var wall_jump_pushoff = 0.0 #This is how much the character move horizontally for a wall jump



func _ready():
	slide_count.Current = slide_count.Max
	if duration.Wait > 0: #If the duration wait is above 0 then a timer will be setup
		controller.setup_timer(duration.Timer, duration.Wait, true, self, "wall_slide_end", [], "WallSlideTimer")


#This handles ending a wall slide
func wall_slide_end():
	if controller.is_on_floor(): #If the player is on the floor
		controller.change_state("Idle") #Set the state to Idle
		controller.change_state_mod("None") #Set the state modifier back to none
	else: #If the player isn't on the floor
		controller.change_state("Fall") #Change the state to Fall
		controller.change_state_mod("None") #Set the state modifier back to none
	
	slide_count.Current -= 1 #Reduce the slide count by 1



