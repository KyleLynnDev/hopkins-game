extends Node3D

@onready var start_game: Button = $"CanvasLayer/VBoxContainer/Start Game"


var rotation_speed = 0.05

func _ready() -> void:
	start_game.grab_focus()

func _process(delta):
	$Camera3D.rotate_y(rotation_speed * delta)

func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://game.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
