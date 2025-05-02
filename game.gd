extends Node


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		get_viewport().mode = (
			Window.MODE_FULLSCREEN if
			get_viewport().mode != Window.MODE_FULLSCREEN else
			Window.MODE_WINDOWED
		)
	if event.is_action_pressed("ui_cancel"): # ui_cancel is the default action for Escape
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
