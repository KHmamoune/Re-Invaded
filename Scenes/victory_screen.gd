extends Control


signal pick_card(card: Node)
signal skiped_card


var cards: Array = []
var j: int = -1


func _ready() -> void:
	create_tween().parallel().tween_property(self, "position:x", 0, 1)
	create_tween().parallel().tween_property(self, "modulate:a", 1, 0.5)
	var card_ui: PackedScene = preload("res://Scenes/card_ui.tscn")
	
	for i in range(0, 3):
		var new_card: Node = card_ui.instantiate()
		new_card.update(gv.cards[floor(randf() * len(gv.cards))])
		cards.append(new_card)
		%reward_cards.add_child(new_card)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_right"):
		cards[j].scale = Vector2(1, 1)
		
		j += 1
		if j >= len(cards):
			j = 0
		
		cards[j].scale = Vector2(1.1, 1.1)
	
	if event.is_action_pressed("move_left"):
		cards[j].scale = Vector2(1, 1)
		
		j -= 1
		if j < 0:
			j = len(cards) - 1
		
		cards[j].scale = Vector2(1.1, 1.1)
	
	if event.is_action_pressed("shoot1"):
		if j == -1:
			return
		
		pick_card.emit(cards[j])


func _on_button_pressed() -> void:
	skiped_card.emit()
