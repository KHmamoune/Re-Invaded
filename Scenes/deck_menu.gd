extends Control


var player_deck: Array = []
var player_modifiers: Dictionary = {}
var card_ui: PackedScene = preload("res://Scenes/card_ui.tscn")
var modifier_ui: PackedScene = preload("res://Scenes/modifier.tscn")
var state: String = "hidden"
var i: int = 0


func update(deck: Array, modifiers: Dictionary) -> void:
	i = 0
	player_deck = deck
	player_modifiers = modifiers
	for child in %Cards.get_children():
		%Cards.remove_child(child)
	
	for child in %Modifiers.get_children():
		%Modifiers.remove_child(child)
	
	for type: String in player_modifiers.keys():
		for modifier: Modifiers.Modifier in player_modifiers[type]:
			var button: TextureButton = TextureButton.new()
			var new_modifier_ui: Node = modifier_ui.instantiate()
			new_modifier_ui.update(modifier)
			button.add_child(new_modifier_ui)
			button.connect("focus_entered", Callable(modifier_focus_entered).bind(new_modifier_ui))
			button.connect("focus_exited", Callable(modifier_focus_exited).bind(new_modifier_ui))
			%Modifiers.add_child(button)
			if i >= 5:
				%Modifiers.get_child(i - 5).focus_neighbor_bottom = button.get_path()
				button.focus_neighbor_top = %Modifiers.get_child(i - 5).get_path()
			if i % 5 > 0:
				%Modifiers.get_child(i - 1).focus_neighbor_right = button.get_path()
				button.focus_neighbor_left = %Modifiers.get_child(i - 1).get_path()
			i += 1
	
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


func modifier_focus_entered(mod: Node) -> void:
	mod.show_details()


func modifier_focus_exited(mod: Node) -> void:
	mod.hide_details()


func focus_entered(card: Node) -> void:
	create_tween().tween_property(card, "scale", Vector2(1, 1), 0.2)
	card.show_details()


func focus_exited(card: Node) -> void:
	create_tween().tween_property(card, "scale", Vector2(0.9, 0.9), 0.2)
	card.hide_details()
