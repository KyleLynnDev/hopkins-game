extends Control

@onready var interaction = %InteractionPrompt
@onready var dialogue = %DialoguePanel
@onready var Observation = %ObservationPanel
@onready var Options = %OptionsMenu

func show_interact_prompt(text: String):
	interaction.text = text
	interaction.visible = true

func hide_interact_prompt():
	interaction.visible = false

func open_dialogue(lines: Array):
	dialogue.show()
	dialogue.set_lines(lines)

func open_observation(data: Dictionary):
	dialogue.show()
	dialogue.set_data(data)
