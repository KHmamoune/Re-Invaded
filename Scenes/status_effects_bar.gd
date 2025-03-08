extends HBoxContainer


var status_ui: PackedScene = preload("res://Scenes/status_effect.tscn")
var prev_se: Dictionary = {}

func update_status_effects(se: Dictionary) -> void:
	for child in get_children():
		if child.status in prev_se.keys():
			if prev_se[child.status]["stack"] != se[child.status]["stack"] or prev_se[child.status]["time"] != se[child.status]["time"]:
				remove_child(child)
	
	prev_se = se
	
	for k: String in se.keys():
		if se[k] == 0:
			continue
		
		var new_se: Node = status_ui.instantiate()
		
		new_se.get_node("Icon").texture_under = gv.status_icons[k]
		new_se.get_node("Icon").texture_progress = gv.status_icons[k]
		new_se.get_node("Stack").text = str(se[k])
		
		add_child(new_se)
