extends StaticBody3D

@export var interact_name: String = "Unknown Object" 

@onready var interact_type : String = "Object"
@onready var display_name : String
@export var description : String
@export var sprite_preview : Texture 

func interact():
	print("You interacted with:", interact_name)
	
	if (interact_type == "Object"): 
		if not GameData.observed_items.has(interact_name):
			GameData.observed_items[interact_name] = {
				"description" : description,
				"sprite" : sprite_preview
			}
			print("Added to GameData:", interact_name)
		else:
			print(interact_name, "was already observed.")	
			
		#now open or close observation 
		if Ui.observation.visible:
			Ui.hide_observation()
		else:
			Ui.show_observation(interact_name, description, sprite_preview)
		
