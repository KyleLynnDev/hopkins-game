extends Button

var item_name = ""
var item_description = ""
var sprite: Texture = null
var unlocked: bool = false

func set_data(name: String, description: String, sprite_texture: Texture, is_unlocked: bool):
	item_name = name
	item_description = description
	sprite = sprite_texture
	unlocked = is_unlocked
	
	if unlocked:
		%ItemSprite.texture = sprite
	else:
		%ItemSprite.texture = preload("res://assets/Objects/unknownObject.png")  # placeholder
		
func _on_pressed():
	if unlocked:
		Ui.show_item_info(item_name, item_description, sprite)
