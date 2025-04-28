extends Control

@onready var interaction = %InteractionPrompt
@onready var dialogue = %DialoguePanel
@onready var observation = %ObservationPanel
@onready var options = %OptionsMenu
@onready var collection = %CollectionUI
@onready var crosshair: ColorRect = $crosshair


func is_ui_open() -> bool:
	return collection.visible or observation.visible or dialogue.visible or options.visible

func show_interact_prompt(text: String):
	interaction.text = text
	interaction.visible = true

func hide_interact_prompt():
	interaction.visible = false

func open_dialogue(lines: Array):
	dialogue.show()
	dialogue.set_lines(lines)
	
func open_collection():
	if(collection.visible == true):
		hide_collection()
	else:
		Ui.refresh_inventory()
		collection.visible = true
	
func hide_observation():
	$ObservationPanel/Panel/ObjectName.text = ""
	$ObservationPanel/Panel/ObjectDescription.text = ""
	$ObservationPanel/Panel/ObjectImage.texture = null
	observation.visible = false
	
func hide_collection():
	collection.visible = false; 
	
	
func show_observation(name: String, description : String, image: Texture):
	$ObservationPanel/Panel/ObjectName.text = name
	$ObservationPanel/Panel/ObjectDescription.text = description
	$ObservationPanel/Panel/ObjectImage.texture = image
	observation.visible = true; 
	
		
func show_item_info(name: String, desc: String, image: Texture):
	$CollectionUI/InfoPanel/TextureRect.texture = image
	$CollectionUI/InfoPanel/Label.text = name
	$CollectionUI/InfoPanel/RichTextLabel.text = desc
	$CollectionUI/InfoPanel.visible = true
	
func close_all_panels():
	hide_interact_prompt()
	hide_observation()
	hide_collection()
	options.visible = false
	dialogue.visible = false
	
func refresh_inventory():
	#print("Refreshing inventory...")
	#print("Observed items:", GameData.observed_items.keys())
	var container = $CollectionUI/GridContainer
	for n in container.get_children():
		container.remove_child(n)
		n.queue_free()

	var observed_names = GameData.observed_items.keys()
	var total_slots = 20  # 5x4 grid
	
	for i in range(total_slots):
		var entry = preload("res://ui/CollectionItem.tscn").instantiate()
		
		if i < observed_names.size():
			var item_name = observed_names[i]
			var item_data = GameData.observed_items[item_name]
			entry.set_data(item_name, item_data["description"], item_data["sprite"], true)
		else:
			entry.set_data("", "", null, false)
		if(container):
			container.add_child(entry)
			
	# 🚨 After adding all the items:
	await get_tree().process_frame  # Wait one frame to ensure they exist
	if container.get_child_count() > 0:
		var first_slot = container.get_child(0)
		first_slot.grab_focus()
	
