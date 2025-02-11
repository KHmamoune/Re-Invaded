extends HBoxContainer


var status_ui: PackedScene = preload("res://Scenes/status_effect.tscn")


func update_status_effects(se: Dictionary) -> void:
	for child in get_children():
		remove_child(child)
	
	for k: String in se.keys():
		if se[k] == 0:
			continue
		
		var new_se: Node = status_ui.instantiate()
		
		new_se.get_node("Icon").texture = gv.status_icons[k]
		new_se.get_node("Stack").text = str(se[k])
		
		add_child(new_se)
