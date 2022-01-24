extends Node2D

signal Hurt
signal Dead

var controller
var move_module

export (int) var health_max #The most health the character can have
onready var health_current = health_max #The current health of the character
export (float) var damage_jump #How much the character moves when damaged
var regen_amount = 0 #The amount that's regenerated
var regen_rate = 0.1 #How fast the health is regenerated
var regen_timer = null



func _ready():
	controller = get_parent().get_parent()
	for module in controller.get_node("Modules").get_children():
		if "Move" in module.name:
			move_module = module
	
	if regen_amount > 0: #Sets up the timer for health regeneration if being used
		controller.setup_timer(regen_timer, regen_rate, false, controller, 
		"modify_stat", [health_current, health_max, regen_amount], "HealthRegenTimer")


#This handles damaging the character
func take_damage(damage, knockback, damage_pos):
	emit_signal("Hurt")
	#Reduce the current health with the modify stat method
	health_current = clamp(health_current - damage, 0, health_max)
	var damage_direction #This just makes it easier to handle the direction the character is being damaged from
	#We take the global position of the character and subtract it from the damage
	#Then we limit it so it can only be right or left at 1 or -1
	damage_direction = clamp(controller.global_position.x - damage_pos.x, -1, 1)
	print(damage_direction)
	
	move_module.velocity.x = damage_direction * knockback #Then set the horizontal velocity to damage jump's value times the direction which knocks us back
	if controller.is_in_group("AI"):
		move_module.move(true)
	
	if health_current == 0:
		emit_signal("Dead")


func disable():
	$Hitbox/AreaCollider.set_deferred("disabled", true)


