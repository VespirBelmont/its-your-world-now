extends Spatial

export (NodePath) var follow_target_path
onready var follow_target = get_node(follow_target_path)

export (float) var rotation_speed = 0.05
export (float) var zoom_speed = 0.05
export (float) var zoom_min = -16
export (float) var zoom_max = -6

export var rotation_allowed = {
								"X": false,
								"Y": false,
								"Z": false
							}

func _process(delta):
	if follow_target == null: return
	
	self.global_transform.origin = follow_target.global_transform.origin
	control_check()

func set_new_target(_new_target):
	set_process(false)
	
	var initial_position = self.global_transform.origin
	var final_position = _new_target.global_transform.origin
	
	$Tween.interpolate_property(self, "translation", 
								initial_position, final_position, 3, 
								Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
								)
	$Tween.start()
	yield($Tween, "tween_completed")
	
	follow_target = _new_target
	
	set_process(true)

func control_check():
	var rotate_y_right = Input.is_action_pressed("RotateYRight") and rotation_allowed.Y
	var rotate_y_left = Input.is_action_pressed("RotateYLeft") and rotation_allowed.Y
	
	var zoom_in = Input.is_action_pressed("ZoomIn")
	var zoom_out = Input.is_action_pressed("ZoomOut")
	
	if rotate_y_right:
		$YRot.rotation.y -= rotation_speed
	if rotate_y_left:
		$YRot.rotation.y += rotation_speed
	
	if zoom_in and $YRot/ZRot/Cam.transform.origin.x < -6:
		$YRot/ZRot/Cam.transform.origin.x += zoom_speed
	if zoom_out and $YRot/ZRot/Cam.transform.origin.x > -20:
		$YRot/ZRot/Cam.transform.origin.x -= zoom_speed


