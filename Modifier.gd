extends Control


@onready var new_modifier: Modifiers.Modifier


func show_details() -> void:
	$DescriptionContainer.visible = true


func hide_details() -> void:
	$DescriptionContainer.visible = false


func update(modifier: Modifiers.Modifier) -> void:
	new_modifier = modifier
	$TextureRect.texture = load(new_modifier.modifier_sprite)
	$DescriptionContainer/Label.text = new_modifier.modifier_description
