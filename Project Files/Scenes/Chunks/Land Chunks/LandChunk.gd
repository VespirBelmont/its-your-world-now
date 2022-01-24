extends Spatial

var solid = false

func get_spawn_point():
	return $CharacterSpawns.get_child(randi()%($CharacterSpawns.get_child_count()-1)).global_transform.origin

func solidify():
	if solid == true: return
	$PhysicsAnim.play("ToggleCollisions")
	solid = true
	for cross in $Crossroads.get_children():
		cross.toggle_orbs()

func show_orbs():
	for cross in $Crossroads.get_children():
		cross.toggle_orbs()

