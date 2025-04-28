extends Control


func refresh_inventory():
	var container = $GridContainer
	container.queue_free_children()

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
		
		container.add_child(entry)
