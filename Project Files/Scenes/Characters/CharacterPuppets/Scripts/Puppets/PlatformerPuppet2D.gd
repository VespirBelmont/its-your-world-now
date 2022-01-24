extends "res://CharacterPuppets/Scripts/Puppets/CharacterCore2D.gd"

var jump_module


func _ready():
	for module in $Modules.get_children():
		if "Jump" in module.name:
			jump_module = module



