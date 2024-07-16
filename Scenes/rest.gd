extends Control


signal bought_card(card: Node, price: int)
signal healed_player(price: int)

@onready var card_ui: PackedScene = preload("res://Scenes/shop_card.tscn")
var heal_price:int = 80
var cards:Array = [[], [], []]
var rands: Array = []
var i: int = 0
var j: int = 0


func _ready() -> void:
	%HealCost.text = str(heal_price)
	for elem in %Cards.get_children():
		var rand: int = floor(randf() * len(gv.other_cards))
		
		while rand in rands:
			rand = floor(randf() * len(gv.other_cards))
		
		rands.append(rand)
		elem.get_node("ShopCard/CardUI").update(gv.other_cards[rand])
		elem.get_node("ShopCard/HBoxContainer/Cost").text = str(gv.other_cards[rand].card_price)
	
	%card1.grab_focus()


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
	buy(%card1)


func _on_card_2_pressed() -> void:
	buy(%card2)


func _on_card_3_pressed() -> void:
	buy(%card3)


func _on_card_4_pressed() -> void:
	buy(%card4)


func _on_card_5_pressed() -> void:
	buy(%card5)


func _on_card_6_pressed() -> void:
	buy(%card6)


func focus(card: Node) -> void:
	if is_instance_valid(card.get_node_or_null("ShopCard")):
		create_tween().tween_property(card.get_node("ShopCard/CardUI"), "scale", Vector2(0.55, 0.55), 0.2)
		card.get_node("ShopCard/CardUI").show_details()


func unfocus(card: Node) -> void:
	if is_instance_valid(card.get_node_or_null("ShopCard")):
		create_tween().tween_property(card.get_node("ShopCard/CardUI"), "scale", Vector2(0.5, 0.5), 0.2)
		card.get_node("ShopCard/CardUI").hide_details()


func buy(card: Node) -> void:
	if is_instance_valid(card.get_node_or_null("ShopCard")):
		bought_card.emit(card.get_node("ShopCard/CardUI"), card.get_node("ShopCard/CardUI").new_card.card_price)


func _on_heal_pressed() -> void:
	healed_player.emit(heal_price)
