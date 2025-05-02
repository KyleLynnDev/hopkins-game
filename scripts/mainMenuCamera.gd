extends Node3D

@onready var camera_pivot #  = TODO:link up camera pivot mnode3d

var rotation_speed = 08

func _process(delta):
	camera_pivot.rotation_degrees.y += delta * rotation_speed
