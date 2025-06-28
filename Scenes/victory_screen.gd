extends Control


signal pick_card(card: Node)
signal pick_modifier(modifier: Node)
signal skiped_card


var card_ui: PackedScene = preload("res://Scenes/card_ui.tscn")
var modifier_ui: PackedScene = preload("res://Scenes/victory_screen_modifier.tscn")
var cards: Array = []
var j: int = -1


func _ready() -> void:
	%Title.position.x = 1000
	%Text.position.x = 1000
	create_tween().parallel().tween_property(%Title, "position:x", 0, 1)
	create_tween().parallel().tween_property(%Text, "position:x", 0, 1)
	create_tween().parallel().tween_property(self, "modulate:a", 1, 0.5)
	create_tween().parallel().tween_property(%Button, "modulate:a", 1, 1)
	
	if gv.current_room_type == Map.Type.MINIBOSS:
		generate_modifier()
		return
	
	generate_cards()


func generate_modifier() -> void:
	var modifier_button: TextureButton = TextureButton.new()
	var new_modifier: Node = modifier_ui.instantiate()
	modifier_button.custom_minimum_size = Vector2(280, 230)
	new_modifier.update(gv.modifiers[floor(randf() * len(gv.modifiers))])
	modifier_button.focus_entered.connect(Callable(focus).bind(new_modifier))
	modifier_button.focus_exited.connect(Callable(unfocus).bind(new_modifier))
	modifier_button.pressed.connect(Callable(choose_modifier).bind(new_modifier))
	modifier_button.add_child(new_modifier)
	%reward_cards.add_child(modifier_button)
	modifier_button.grab_focus()


func generate_cards() -> void:
	for i in range(0, 3):
		var card_button: TextureButton = TextureButton.new()
		var new_card: Node = card_ui.instantiate()
		new_card.update(gv.cards[floor(randf() * len(gv.cards))])
		cards.append(new_card)
		card_button.custom_minimum_size = Vector2(240, 320)
		card_button.focus_entered.connect(Callable(focus).bind(new_card))
		card_button.focus_exited.connect(Callable(unfocus).bind(new_card))
		card_button.pressed.connect(Callable(choose_card).bind(new_card))
		card_button.add_child(new_card)
		%reward_cards.add_child(card_button)
		new_card.position.x -= 3000
	
	for card in %reward_cards.get_children():
		create_tween().tween_property(card.get_child(0), "position:x", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		await get_tree().create_timer(0.2).timeout
		Audio.play_sfx(Audio.sfx_card_move)
	
	%reward_cards.get_child(0).grab_focus()


func focus(card: Node) -> void:
	create_tween().tween_property(card, "scale", Vector2(1.1, 1.1), 0.2)
	card.show_details()


func unfocus(card: Node) -> void:
	create_tween().tween_property(card, "scale", Vector2(1, 1), 0.2)
	card.hide_details()


func choose_card(card: Node) -> void:
	release_focus()
	pick_card.emit(card)


func choose_modifier(modifier: Node) -> void:
	release_focus()
	pick_modifier.emit(modifier)


func _on_button_pressed() -> void:
	skiped_card.emit()
