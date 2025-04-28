extends StaticBody3D

@export var interact_name: String = "Unknown Object" 

@onready var interact_type : String = "Object"
@onready var display_name : String
@export var description : String
@export var sprite_preview : Texture 

func interact():
	print("You interacted with:", interact_name)
	
	if (interact_type == "Object"): 
		Ui.show_observation(display_name, description, sprite_preview)
		
		if not GameData.observed_items.has(display_name):
			GameData.observed_items[display_name] = {
				"description" : description,
				"sprite" : sprite_preview
			}
		#else:
		#	Ui.hide_observation()
