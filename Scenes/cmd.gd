extends LineEdit


signal add_card_to_player(card: Card.CardStats)
var parrent_state: String = "hidden"


func _ready() -> void:
	text = ""


func _on_text_submitted(new_text: String) -> void:
	var text_segments: Array = new_text.split(" ")
	
	match text_segments[0]:
		"give":
			if len(text_segments) >= 2:
				match text_segments[1]:
					"card":
						if len(text_segments) >= 3:
							if gv.cards_dictionary.has(text_segments[2]):
								add_card_to_player.emit(gv.cards_dictionary[text_segments[2]])
	
	get_parent().hide()
	gv.current_scene.command_state = "hidden"
	release_focus()
	gv.current_scene.player.state = "post_combat"
