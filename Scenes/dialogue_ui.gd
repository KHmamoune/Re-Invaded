extends Control


signal dialogue_done


var dialogue_script: Array = []
var text_color: Color
var i: int = 0


func _ready() -> void:
	match dialogue_script[0]["color"]:
		"blue":
			text_color = Color.BLUE
		"orange":
			text_color = Color.ORANGE
		"red":
			text_color = Color.RED
		"green":
			text_color = Color.GREEN
		"yellow":
			text_color = Color.YELLOW
		"violet":
			text_color = Color.VIOLET
		"gray":
			text_color = Color.GRAY
	
	if dialogue_script[0]["side"] == "up":
		$dialogueup.visible = true
		$dialogueup/HBoxContainer/Label.text = dialogue_script[0]["text"]
		$dialogueup/HBoxContainer/Label.set("theme_override_colors/font_color", text_color)
	elif dialogue_script[0]["side"] == "down":
		$dialoguedown.visible = true
		$dialoguedown/HBoxContainer/Label.text = dialogue_script[0]["text"]
		$dialoguedown/HBoxContainer/Label.set("theme_override_colors/font_color", text_color)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot1"):
		scroll_dialogue()


func scroll_dialogue() -> void:
	i += 1
	if i < len(dialogue_script):
		match dialogue_script[i]["color"]:
			"blue":
				text_color = Color.BLUE
			"orange":
				text_color = Color.ORANGE
			"red":
				text_color = Color.RED
			"green":
				text_color = Color.GREEN
			"yellow":
				text_color = Color.YELLOW
			"violet":
				text_color = Color.VIOLET
			"gray":
				text_color = Color.GRAY
		
		if dialogue_script[i]["side"] == "up":
			$dialogueup.visible = true
			$dialogueup/HBoxContainer/Label.text = dialogue_script[i]["text"]
			$dialogueup/HBoxContainer/Label.set("theme_override_colors/font_color", text_color)
			
		elif dialogue_script[i]["side"] == "down":
			$dialoguedown.visible = true
			$dialoguedown/HBoxContainer/Label.text = dialogue_script[i]["text"]
			$dialoguedown/HBoxContainer/Label.set("theme_override_colors/font_color", text_color)
		
	else:
		emit_signal("dialogue_done")
		queue_free()
