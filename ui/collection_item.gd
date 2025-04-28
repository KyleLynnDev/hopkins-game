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
	
	#print("Slot set_data:", name, unlocked)
	#print("Setting slot:", name, unlocked, "Sprite valid?", sprite_texture != null)
	
	if unlocked:
		%ItemSprite.texture = sprite
		%ItemName.text = name
	else:
		%ItemSprite.texture = preload("res://assets/Objects/unknownObject.png")  # placeholder
		%ItemName.text = "???"
		
func _on_pressed():
	if unlocked:
		Ui.show_item_info(item_name, item_description, sprite)
