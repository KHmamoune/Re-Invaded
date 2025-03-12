extends HBoxContainer


var status_ui: PackedScene = preload("res://Scenes/status_effect.tscn")
var prev_se: Dictionary = {}
var active_statuses: Array = []

func update_status_effects(se: Dictionary) -> void:
	active_statuses = []
	print(prev_se)
	print(se)
	for child in get_children():
		active_statuses.append(child.status)
		if child.status in prev_se.keys():
			var current_stack: int = prev_se[child.status]["stack"]
			var current_time: float = prev_se[child.status]["time"]
			var new_stack: int = se[child.status]["stack"]
			var new_time: float = se[child.status]["time"]
			if current_stack != new_stack or current_time != new_time:
				if new_time == 0.0 or new_stack == 0:
					remove_child(child)
				else:
					child.stack = new_stack
					child.time = new_time
					child.update()
	
	for k: String in se.keys():
		if se[k]["stack"] == 0:
			continue
		
		if k in active_statuses:
			continue
		
		var new_se: Node = status_ui.instantiate()
		
		new_se.get_node("Icon").texture_under = gv.status_icons[k]
		new_se.get_node("Icon").texture_progress = gv.status_icons[k]
		new_se.get_node("Stack").text = str(se[k])
		new_se.status = k
		new_se.stack = se[k]["stack"]
		new_se.time = se[k]["time"]
		
		add_child(new_se)
	
	prev_se = se.duplicate(true)
