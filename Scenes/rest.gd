extends Control


signal bought_card(card: Node, price: int)
signal bought_modifier(modifier: Node, price: int)
signal healed_player(price: int, ui: Node)
signal refreshed(price: int, ui: Node)

@onready var card_ui: PackedScene = preload("res://Scenes/shop_card.tscn")
var heal_price:int = 80
var refresh_price:int = 40
var cards:Array = [[], [], []]
var rands: Array = []
var i: int = 0
var j: int = 0


func _ready() -> void:
	update_labels()
	update_shop()
	%card1.grab_focus()


func update_labels() -> void:
	%HealCost.text = str(heal_price)
	%RefreshCost.text = str(refresh_price)


func update_shop() -> void:
	for elem in %Cards.get_children():
		var rand: int = floor(randf() * len(gv.cards))
		
		rand = floor(randf() * len(gv.cards))
		
		rands.append(rand)
		if is_instance_valid(elem.get_node("ShopCard/CardUI")):
			elem.get_node("ShopCard/CardUI").update(gv.cards[rand])
			elem.get_node("ShopCard/HBoxContainer/Cost").text = str(gv.cards[rand].card_price)
	
	rands = []
	
	for elem in %Modifiers.get_children():
		var rand: int = floor(randf() * len(gv.modifiers))
		
		while rand in rands:
			rand = floor(randf() * len(gv.modifiers))
		
		rands.append(rand)
		if is_instance_valid(elem.get_node("ShopModifier/Modifier")):
			elem.get_node("ShopModifier/Modifier").update(gv.modifiers[rand])
			elem.get_node("ShopModifier/HBoxContainer/Cost").text = str(gv.modifiers[rand].modifier_price)


func _on_card_1_focus_entered() -> void:
	focus(%card1)


func _on_card_1_focus_exited() -> void:
	unfocus(%card1)


func _on_card_2_focus_entered() -> void:
	focus(%card2)


func _on_card_2_focus_exited() -> void:
	unfocus(%card2)


func _on_card_3_focus_entered() -> void:
	focus(%card3)


func _on_card_3_focus_exited() -> void:
	unfocus(%card3)


func _on_card_4_focus_entered() -> void:
	focus(%card4)


func _on_card_4_focus_exited() -> void:
	unfocus(%card4)


func _on_card_5_focus_entered() -> void:
	focus(%card5)


func _on_card_5_focus_exited() -> void:
	unfocus(%card5)


func _on_card_6_focus_entered() -> void:
	focus(%card6)


func _on_card_6_focus_exited() -> void:
	unfocus(%card6)


func _on_card_1_pressed() -> void:
	buy_card(%card1)


func _on_card_2_pressed() -> void:
	buy_card(%card2)


func _on_card_3_pressed() -> void:
	buy_card(%card3)


func _on_card_4_pressed() -> void:
	buy_card(%card4)


func _on_card_5_pressed() -> void:
	buy_card(%card5)


func _on_card_6_pressed() -> void:
	buy_card(%card6)


func focus(card: Node) -> void:
	if is_instance_valid(card.get_node_or_null("ShopCard")):
		create_tween().tween_property(card.get_node("ShopCard/CardUI"), "scale", Vector2(0.55, 0.55), 0.2)
		card.get_node("ShopCard/CardUI").show_details()


func unfocus(card: Node) -> void:
	if is_instance_valid(card.get_node_or_null("ShopCard")):
		create_tween().tween_property(card.get_node("ShopCard/CardUI"), "scale", Vector2(0.5, 0.5), 0.2)
		card.get_node("ShopCard/CardUI").hide_details()


func buy_card(card: Node) -> void:
	if is_instance_valid(card.get_node_or_null("ShopCard")):
		bought_card.emit(card.get_node("ShopCard/CardUI"), card.get_node("ShopCard/CardUI").new_card.card_price)


func buy_modifier(modifier: Node) -> void:
	if is_instance_valid(modifier.get_node_or_null("ShopModifier")):
		bought_modifier.emit(modifier.get_node("ShopModifier/Modifier"), modifier.get_node("ShopModifier/Modifier").new_modifier.modifier_price)


func _on_heal_pressed() -> void:
	healed_player.emit(heal_price, self)
	update_labels()


func _on_refresh_pressed() -> void:
	refreshed.emit(refresh_price, self)
	update_labels()


func _on_modifier_1_pressed() -> void:
	buy_modifier(%Modifier1)


func _on_modifier_1_focus_entered() -> void:
	if is_instance_valid(%Modifier1.get_node_or_null("ShopModifier")):
		create_tween().tween_property(%Modifier1.get_node("ShopModifier/Modifier"), "scale", Vector2(1.1, 1.1), 0.2)
		%Modifier1.get_node("ShopModifier/Modifier").show_details()


func _on_modifier_1_focus_exited() -> void:
	if is_instance_valid(%Modifier1.get_node_or_null("ShopModifier")):
		create_tween().tween_property(%Modifier1.get_node("ShopModifier/Modifier"), "scale", Vector2(1, 1), 0.2)
		%Modifier1.get_node("ShopModifier/Modifier").hide_details()


func _on_modifier_2_pressed() -> void:
	buy_modifier(%Modifier2)


func _on_modifier_2_focus_entered() -> void:
	if is_instance_valid(%Modifier2.get_node_or_null("ShopModifier")):
		create_tween().tween_property(%Modifier2.get_node("ShopModifier/Modifier"), "scale", Vector2(1.1, 1.1), 0.2)
		%Modifier2.get_node("ShopModifier/Modifier").show_details()


func _on_modifier_2_focus_exited() -> void:
	if is_instance_valid(%Modifier2.get_node_or_null("ShopModifier")):
		create_tween().tween_property(%Modifier2.get_node("ShopModifier/Modifier"), "scale", Vector2(1, 1), 0.2)
		%Modifier2.get_node("ShopModifier/Modifier").hide_details()


func _on_modifier_3_pressed() -> void:
	buy_modifier(%Modifier3)


func _on_modifier_3_focus_entered() -> void:
	if is_instance_valid(%Modifier3.get_node_or_null("ShopModifier")):
		create_tween().tween_property(%Modifier3.get_node("ShopModifier/Modifier"), "scale", Vector2(1.1, 1.1), 0.2)
		%Modifier3.get_node("ShopModifier/Modifier").show_details()


func _on_modifier_3_focus_exited() -> void:
	if is_instance_valid(%Modifier3.get_node_or_null("ShopModifier")):
		create_tween().tween_property(%Modifier3.get_node("ShopModifier/Modifier"), "scale", Vector2(1, 1), 0.2)
		%Modifier3.get_node("ShopModifier/Modifier").hide_details()
