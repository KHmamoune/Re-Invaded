extends Control


@onready var new_card: Card.CardStats
var tooltip: PackedScene = preload("res://Scenes/tool_tip.tscn")
var card_ui: PackedScene = preload("res://Scenes/card_ui.tscn")


func show_details() -> void:
	@warning_ignore("untyped_declaration")
	for tip in new_card.card_tooltips:
		if typeof(tip) == typeof(Card.CardStats):
			var mini_card: Node = card_ui.instantiate()
			mini_card.update(tip)
			%ToolTips.add_child(mini_card)
			mini_card.scale = Vector2(0.8, 0.8)
			continue
		
		var new_tooltip: Node = tooltip.instantiate()
		new_tooltip.update(tip)
		%ToolTips.add_child(new_tooltip)


func hide_details() -> void:
	for child in %ToolTips.get_children():
		%ToolTips.remove_child(child)
		child.queue_free()


func update(card: Card.CardStats) -> void:
	new_card = card
	%CardName.text = new_card.card_name
	%CardCost.text = str(new_card.card_cost)
	%CardType.text = new_card.card_type
	%CardImage.texture = load(new_card.card_image)
	%CardDescription.text = new_card.card_description
	$CardBackground.modulate = card.card_color
