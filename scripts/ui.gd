extends Control

@onready var interaction = %InteractionPrompt
@onready var dialogue = %DialoguePanel
@onready var observation = %ObservationPanel
@onready var options = %OptionsMenu
@onready var collection = %CollectionUI

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

func open_observation(data: Dictionary):
	observation.show()
	observation.set_data(data)
	
func open_collection():
	refresh_collection()
	%CollectionUI.visible = !%CollectionUI.visible;
	
func hide_observation():
	observation.hide()
	
func show_observation(name: String, description : String, image: Texture):
	$ObservationPanel/Panel/ObjectName.text = name
	$ObservationPanel/Panel/ObjectDescription.text = description
	$ObservationPanel/Panel/ObjectImage.texture = image
	observation.visible = true; 
	
func refresh_collection():
	var container = $CollectionUI/ScrollContainer/VBoxContainer
	#container.clear_children()
	var children = container.get_children()
	for child in children:
		child.free()
	
	for name in GameData.observed_items.keys():
		var data = GameData.observed_items[name]
		var entry = preload("res://ui/CollectionItem.tscn").instantiate()
		entry.set_data(name, data.description, data.sprite)
		container.add_child(entry)
		
	# Auto-focus the first entry
	if container.get_child_count() > 0:
		var first = container.get_child(0)
		first.grab_focus()
