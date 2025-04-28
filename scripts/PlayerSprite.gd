# sophia_skin.gd
extends Node3D

@onready var sprite = $AnimatedSprite3D

func idle():
	sprite.play("idle")

func move():
	sprite.play("run")

func jump():
	sprite.play("run")  # You can separate if you want different jump frames

func fall():
	sprite.play("run")  # Same here, optional

# Flip sprite depending on input direction
func set_facing_direction(direction: Vector2):
	if direction.x != 0:
		sprite.flip_h = direction.x < 0
