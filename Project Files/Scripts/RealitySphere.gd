extends Spatial

signal Collected

export (PackedScene) var sphere_content

func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("Collected", self.duplicate())
		self.queue_free()

func used():
	self.queue_free()
