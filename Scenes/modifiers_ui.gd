extends Control


func update(modifiers: Dictionary) -> void:
	for child in $GridContainer.get_children():
		$GridContainer.remove_child(child)
	
	for key: String in modifiers.keys():
		for modifier: Modifiers.Modifier in modifiers[key]:
			var modifier_ui: Node = preload("res://Scenes/modifier.tscn").instantiate()
			modifier_ui.update(modifier)
			$GridContainer.add_child(modifier_ui)
