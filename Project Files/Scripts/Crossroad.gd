extends Spatial

signal UpdateAttachment

var world_builder

func _ready():
	world_builder = get_parent().get_parent().get_parent().get_parent()
	
	self.connect("UpdateAttachment", world_builder, "update_land_info")

func set_attachment_point():
	var position = $AttachmentPoint.global_transform.origin
	emit_signal("UpdateAttachment", position, $AttachmentPoint)
	
	world_builder.land_spawn_pos = position


func _on_PlayerDetectionArea_body_entered(body):
	if body.is_in_group("Player"):
		set_attachment_point()
		
		
		if WorldManager.lands_shards_owned <= 0:
			$Controls/NoLand.show()
			print("Crossroad.gd | No Land Left")
		else:
			$Controls/ToggleButton.show()
			world_builder.set_activation_status(true)
			if not world_builder.active:
				world_builder.change_menu("Land")

func _on_PlayerDetectionArea_body_exited(body):
	if body.is_in_group("Player"):
		world_builder.set_activation_status(false)
		
		$Controls/ToggleButton.hide()
		$Controls/NoLand.hide()

func toggle_orbs():
	if not $CrossroadDetection/ConnectedOrb_3.visible:
		$CrossroadDetection/ConnectedOrb_3.show()
	else:
		$CrossroadDetection/ConnectedOrb_3.hide()

func turn_orbs_on():
	$Spire/ConnectedOrb_1/Connected.show()
	$Spire/ConnectedOrb_1/NotConnected.hide()
	
	$Spire/ConnectedOrb_2/Connected.show()
	$Spire/ConnectedOrb_2/NotConnected.hide()
	
	$CrossroadDetection/ConnectedOrb_3/Connected.show()
	$CrossroadDetection/ConnectedOrb_3/NotConnected.hide()

func turn_orbs_off():
	$Spire/ConnectedOrb_1/Connected.hide()
	$Spire/ConnectedOrb_1/NotConnected.show()
	
	$Spire/ConnectedOrb_2/Connected.hide()
	$Spire/ConnectedOrb_2/NotConnected.show()
	
	$CrossroadDetection/ConnectedOrb_3/Connected.hide()
	$CrossroadDetection/ConnectedOrb_3/NotConnected.show()

func crossroad_detected(area):
	if area != $CrossroadDetection:
		turn_orbs_on()

func crossroad_left(area):
	if area != $CrossroadDetection:
		turn_orbs_off()

func try_to_connect_land():
	if $CrossroadDetection/ConnectedOrb_3/Connected.visible:
		$Spatial/Bridge/Anim.play("Extend")
		$PlayerDetectionArea/CollisionShape.set_deferred("disabled", true)
		$Controls.hide()
		get_parent().get_parent().solidify()
		return true
	
	return false
