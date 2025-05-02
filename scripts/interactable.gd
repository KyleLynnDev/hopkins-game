extends StaticBody3D

@export var interact_name: String = "Unknown Object" 

@onready var interact_type : String = "Object"

@onready var display_name : String
@export var description : String
@export var sprite_preview : Texture 

@export var npc_name: String = ""  # Optional — leave blank for non-NPCs

var npc_dialogue_pools = {
	"crab_guy": [
		"res://dialogue/crab_guy_1.dialogue",
		"res://dialogue/crab_guy_2.dialogue",
		"res://dialogue/crab_guy_3.dialogue",
	],
	"marine_biologist": [
		"res://timelines/bio_1dialogue.dtl"
	],
	"seal_child": [
		"res://dialogue/seal_child.dialogue"
	]
}

func _ready():
	randomize()


func interact():
	print("You interacted with:", interact_name)
	
	# 🔹 If this is an NPC and has dialogue, start a random Dialogic timeline
	if npc_name != "" and npc_dialogue_pools.has(npc_name):
		var pool = npc_dialogue_pools[npc_name]
		if pool.size() > 0:
			var random_timeline = pool[randi() % pool.size()]
			print("Starting random dialogue:", random_timeline)
			Dialogic.start(random_timeline)
			return
		else:
			print("Warning: No dialogue timelines defined for", npc_name)

	# 🔸 Otherwise, handle it as an Object with observation behavior
	
	
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
		
