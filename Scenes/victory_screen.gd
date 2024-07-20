extends Control


signal pick_card(card: Node)
signal skiped_card


var cards: Array = []
var j: int = -1


func _ready() -> void:
	%reward_cards.position.x = -1000
	%Title.position.x = 1000
	%Text.position.x = 1000
	create_tween().parallel().tween_property(%Title, "position:x", 0, 1)
	create_tween().parallel().tween_property(%Text, "position:x", 0, 1)
	create_tween().parallel().tween_property(%reward_cards, "position:x", 0, 1)
	create_tween().parallel().tween_property(self, "modulate:a", 1, 0.5)
	create_tween().parallel().tween_property(%Button, "modulate:a", 1, 1)
	var card_ui: PackedScene = preload("res://Scenes/card_ui.tscn")
	
	for i in range(0, 3):
		var card_button: TextureButton = TextureButton.new()
		var new_card: Node = card_ui.instantiate()
		new_card.update(gv.cards[floor(randf() * len(gv.cards))])
		cards.append(new_card)
		card_button.custom_minimum_size = Vector2(240, 320)
		card_button.focus_entered.connect(Callable(focus).bind(new_card))
		card_button.focus_exited.connect(Callable(unfocus).bind(new_card))
		card_button.pressed.connect(Callable(pick).bind(new_card))
		card_button.add_child(new_card)
		%reward_cards.add_child(card_button)
		
		if i == 0:
			card_button.grab_focus()


func focus(card: Node) -> void:
	create_tween().tween_property(card, "scale", Vector2(1.1, 1.1), 0.2)
	card.show_details()


func unfocus(card: Node) -> void:
	create_tween().tween_property(card, "scale", Vector2(1, 1), 0.2)
	card.hide_details()


func pick(card: Node) -> void:
	release_focus()
	pick_card.emit(card)


func _on_button_pressed() -> void:
	skiped_card.emit()
