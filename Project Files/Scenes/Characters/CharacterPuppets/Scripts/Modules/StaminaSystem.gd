extends Node

export var stamina_settings = { #Settings for the Stamina System [Ignore if you're not using it]
		   "Active": false, #This determines if this system is being used
		   "Max": 0.0, #The max stamina for the character
		   "Current": 0.0, #The current stamina for the character
		   
		   "Regen": { #Stamina Regen settings [Ignore if you're not using it]
					 "Amount": 0.0, #How much the character regenerates
					 "Rate": 0.1, #How fast the character regenerates
					 "Timer": null, #The timer that will be generated and used to time regeneration
					},
			
			"Costs": { #The stamina cost of each action
					  "None": 0.0, 
					  "Walk": 0.0,
					  "Run": 0.0,
					  "Sprint": 0.0,
					  "JumpLaunch": 0.0,
					  "JumpContinue": 0.0,
					 },
}

#func _ready():
#	if stamina_settings.Regen.Amount > 0: #Sets up the timer for the stamina regeneration if being used
#		setup_timer(stamina_settings.Regen.Timer, stamina_settings.Regen.Rate, false, self, "modify_stat", [stamina_settings.Current, stamina_settings.Max, stamina_settings.Regen.Amount, "Stamina Gen"], "StaminaRegenTimer")
