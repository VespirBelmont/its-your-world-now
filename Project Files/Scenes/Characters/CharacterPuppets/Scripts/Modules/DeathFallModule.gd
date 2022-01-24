extends Node2D

signal death_by_fall

export (float) var death_height = 0.0


func _process(delta):
	if global_position.y >= death_height:
		set_process(false)
		emit_signal("death_by_fall")


