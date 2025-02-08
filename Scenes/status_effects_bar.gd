extends HBoxContainer


var status_ui: PackedScene = preload("res://Scenes/status_effect.tscn")


func update_status_effects(se: Dictionary) -> void:
	for child in get_children():
		remove_child(child)
	
	for k: String in se.keys():
		if se[k] == 0:
			continue
		
		var new_se: Node = status_ui.instantiate()
		
		match k:
			"flame":
				new_se.get_node("Icon").texture = preload("res://Images/Icons/flame.png")
			"impede":
				new_se.get_node("Icon").texture = preload("res://Images/Icons/impede.png")
			"generation boost":
				new_se.get_node("Icon").texture = preload("res://Images/Icons/gen_boost.png")
			"heat":
				new_se.get_node("Icon").texture = preload("res://Images/Icons/heat.png")
			"reinforce":
				new_se.get_node("Icon").texture = preload("res://Images/Icons/reinforced.png")
			"endurance":
				new_se.get_node("Icon").texture = preload("res://Images/Icons/endurance.png")
			
		new_se.get_node("Stack").text = str(se[k])
		
		add_child(new_se)
