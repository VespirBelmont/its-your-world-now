extends Node2D

signal target_found
signal target_lost

export (Array, String) var target_list = []
var target = null


func get_target(collided):
	var current_target_priority = 0
	var new_target_priority = 0
	
	for t in target_list:
		if is_instance_valid(target):
			if target.is_in_group(t):
				break
		current_target_priority += 1
	
	for p in target_list:
		if collided.is_in_group(p):
			if target == null or new_target_priority < current_target_priority:
				target = collided
				emit_signal("target_found")
				$DetectionArea/AreaCollider.set_deferred("disabled", true)
				yield(get_tree().create_timer(0.2), "timeout")
				$DetectionArea/AreaCollider.set_deferred("disabled", false)
				return
		
		new_target_priority += 1


func lost_entity(collided):
	if collided == target:
		emit_signal("target_lost")
		target = null


