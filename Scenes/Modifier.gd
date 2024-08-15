extends Control


@onready var new_modifier: Modifiers.Modifier
var card_ui: PackedScene = preload("res://Scenes/card_ui.tscn")
var tooltip: PackedScene = preload("res://Scenes/tool_tip.tscn")


func show_details() -> void:
	%DescriptionContainer.visible = true
	create_tween().tween_property($Sprite, "scale", Vector2(1.2, 1.2), 0.2)
	
	@warning_ignore("untyped_declaration")
	for tip in new_modifier.modifier_tooltips:
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
	%DescriptionContainer.visible = false
	create_tween().tween_property($Sprite, "scale", Vector2(1, 1), 0.2)
	
	for child in %ToolTips.get_children():
		%ToolTips.remove_child(child)
		child.queue_free()


func update(modifier: Modifiers.Modifier) -> void:
	new_modifier = modifier
	$Sprite.texture = load(new_modifier.modifier_sprite)
	%Name.text = new_modifier.modifier_name + ":"
	%Description.text = new_modifier.modifier_description
