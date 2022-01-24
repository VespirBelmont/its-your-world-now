extends Spatial

var next_anim = ""

func play_anim():
	if $Body/Anim.has_animation(next_anim):
		$Body/Anim.play(next_anim)
	
	next_anim = ""
