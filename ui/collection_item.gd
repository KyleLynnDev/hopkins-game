extends Button

func set_data(name: String, description: String, sprite: Texture) -> void:
	%ItemSprite.texture = sprite
	%ItemName.text = name
	# Optional: Store other data if needed
	self.name = name  # Helpful if you want to reference this later
