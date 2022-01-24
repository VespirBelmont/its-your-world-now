extends Node

signal moving_right
signal moving_left


var controller
var target_module

var velocity = Vector2()
export (float) var move_speed = 1.0

export (bool) var does_idle = true
export (float) var idle_duration = 0.1

var current_point = 0

export (float) var gravity = 100 #The gravity amount that'll pull the character down
export (float) var gravity_fall_mod #The amount gravity is modified when falling [More in the Documentation Document]



func _ready():
	controller = get_parent().get_parent()
	
	for module in get_parent().get_children():
		if "Target" in module.name:
			target_module = module


func get_velocity():
	var target 
	
	if target_module != null:
		if target_module.target != null:
			target = target_module.target.global_position
	
	if target == null:
		target = get_child(current_point).global_position
	
	var distance = abs(target.x - controller.global_position.x)
	if distance <= 0.1:
		target_reached()
	
	var dir = target - controller.global_position
	
	if dir.x > 0: 
		dir.x = 1
		emit_signal("moving_right")
	if dir.x < 0: 
		dir.x = -1
		emit_signal("moving_left")
	
	velocity.x = move_speed * dir.x


func target_reached():
	if target_module == null or target_module.target == null:
		current_point += 1
	
	if current_point > get_child_count() - 1:
		current_point = 0


func move(force = false):
	if not force:
		get_velocity()
	
	controller.move_and_slide(velocity, Vector2.UP)


#This handles applying gravity to the character
func apply_gravity(delta):
	var final_gravity = gravity #This will allow us to modify the value of gravity without changing it
	
	if (velocity.y > 0): #If the character is falling
		final_gravity += gravity_fall_mod #Gravity Fall modifier is added to the final gravity
	
	velocity.y += final_gravity * delta #Then we add the final gravity smoothed out with delta which will move the character down nicely


