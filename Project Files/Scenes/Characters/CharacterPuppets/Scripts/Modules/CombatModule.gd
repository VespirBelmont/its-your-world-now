extends Node2D

signal attack_connected


export (Array, String) var effected_groups = []

export var attack_list = {
							"Jump": {
									 "Damage": 1,
									 "Knockback": 1,
									 "EnableOnHit": false, 
									}
						 }
var active_attack = "None"



func activate_attack(attack_name):
	$Hitbox/AreaCollider.set_deferred("disabled", false)
	active_attack = attack_name


func deactivate_attack(targeted_attack):
	if targeted_attack == active_attack:
		$Hitbox/AreaCollider.set_deferred("disabled", true)
		active_attack = "None"


func attack_connected(area):
	for group in effected_groups:
		if active_attack in attack_list:
			var damage = attack_list[active_attack].Damage
			var knockback = attack_list[active_attack].Knockback
			
			if area.is_in_group(group):
				emit_signal("attack_connected", active_attack)
				area.get_parent().take_damage(damage, knockback, global_position)
				
				if not attack_list[active_attack].EnableOnHit:
					deactivate_attack(active_attack)


