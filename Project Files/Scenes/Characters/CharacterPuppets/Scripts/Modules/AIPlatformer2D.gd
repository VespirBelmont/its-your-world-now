extends "res://CharacterPuppets/Scripts/Puppets/PlatformerPuppet2D.gd"

var current_action = "Patrol"
export (Array) var actions

func _physics_process(delta):
	if move_module == null:
		return
	
	move_module.apply_gravity(delta)
	
	if current_action == "Patrol":
		move_module.move()


func action_execute():
	match current_action:
		"Patrol":
			pass
		"Idle":
			pass


func death():
	health_module.disable()
	set_physics_process(false)
	yield(get_tree().create_timer(1.1), "timeout")
	queue_free()


