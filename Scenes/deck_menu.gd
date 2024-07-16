extends Control


var player_deck: Array = []
var card_ui: PackedScene = preload("res://Scenes/card_ui.tscn")
var state: String = "hidden"


func update(deck: Array) -> void:
	player_deck = deck
	for child in %Cards.get_children():
		%Cards.remove_child(child)
	
	for card: Card.CardStats in player_deck:
		var button: TextureButton = TextureButton.new()
		var new_card_ui: Node = card_ui.instantiate()
		new_card_ui.scale = Vector2(0.9, 0.9)
		new_card_ui.update(card)
		button.add_child(new_card_ui)
		button.custom_minimum_size = Vector2(240, 320)
		button.connect("focus_entered", Callable(focus_entered).bind(new_card_ui))
		button.connect("focus_exited", Callable(focus_exited).bind(new_card_ui))
		%Cards.add_child(button)


func focus_entered(card: Node) -> void:
	create_tween().tween_property(card, "scale", Vector2(1, 1), 0.2)
	card.show_details()


func focus_exited(card: Node) -> void:
	create_tween().tween_property(card, "scale", Vector2(0.9, 0.9), 0.2)
	card.hide_details()
