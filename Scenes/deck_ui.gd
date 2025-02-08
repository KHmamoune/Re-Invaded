extends Control


@onready var deck: Array = []
var current_hand: Array = []
var card1_used: bool = false
var card2_used: bool = false
var on_cooldown: bool = false
var i: int = 0


func update_deck() -> void:
	var cards: Array = []
	
	for child: Node in %Deck.get_children():
		child.queue_free()
	
	for child: Node in %Cards.get_children():
		child.queue_free()
	
	for card: Card.CardStats in deck:
		if i == 5:
			break
		
		var rect: TextureRect = TextureRect.new()
		var cost: Label = create_label(card)
		rect.custom_minimum_size = Vector2(80, 80)
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.modulate.a = 0.8 - i * 0.05
		rect.texture = load(card.card_image)
		rect.add_child(cost)
		cards.push_front(rect)
		i += 1
	i = 0
	
	for card: Node in cards:
		%Deck.add_child(card)
	
	for card: Card.CardStats in current_hand:
		var rect: TextureRect = TextureRect.new()
		
		rect.custom_minimum_size = Vector2(80, 80)
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		
		if card != null:
			var cost: Label = create_label(card)
			rect.texture = load(card.card_image)
			rect.add_child(cost)
		
		%Cards.add_child(rect)


func show_delay(delay: float) -> void:
	for child: Node in %Deck.get_children():
		child.queue_free()
	
	for child: Node in %Cards.get_children():
		child.queue_free()
	
	$DelayBar.show()
	$DelayBar.max_value = delay
	$DelayTimer.start(delay)
	
	while($DelayTimer.time_left > 0):
		$DelayBar.value = $DelayTimer.time_left
		await get_tree().create_timer(0.001).timeout
	
	$DelayBar.hide()


func create_label(card: Card.CardStats) -> Label:
	var cost: Label = Label.new()
	cost.text = str(card.card_cost)
	cost.anchor_right = 1
	cost.anchor_bottom = 1
	cost.grow_horizontal = Control.GROW_DIRECTION_BOTH
	cost.grow_vertical =Control.GROW_DIRECTION_BOTH
	cost.add_theme_font_size_override("font_size", 64)
	cost.add_theme_constant_override("outline_size", 8)
	cost.add_theme_color_override("font_outline_color", Color.BLACK)
	cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return cost
