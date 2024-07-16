extends Control


signal move_main
signal player_selected

@onready var character_sel: Node = $MarginContainer/characterSelect
@onready var char_pic: Node = $MarginContainer/characterInfo/HBoxContainer/TextureRect
@onready var char_name: Node = $MarginContainer/characterInfo/HBoxContainer/VBoxContainer/description/Label
@onready var char_desc: Node = $MarginContainer/characterInfo/HBoxContainer/VBoxContainer/description/Label2


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		emit_signal("move_main")


func _on_blue_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property($Cursor, "position", character_sel.position + Vector2(40, 35), 0.1)
	set_info(%Blue, "Code Blue:", Color.BLUE, "a fighter specialized in rapid fire weaponry and enhancement technology")


func _on_orange_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property($Cursor, "position", character_sel.position + Vector2(140, 35), 0.1)
	set_info(%Orange, "Code Orange:", Color.ORANGE, "a fighter specialized in explosive weaponry and flame throwers")


func _on_red_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property($Cursor, "position", character_sel.position + Vector2(240, 35), 0.1)
	set_info(%Red, "Code Red:", Color.RED, "a fighter specialized in wide range weaponry and trade enhancements")


func _on_green_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property($Cursor, "position", character_sel.position + Vector2(40, 135), 0.1)
	set_info(%Green, "Code Green:", Color.GREEN, "a fighter specialized in auto aim weaponry and defensive technology")


func _on_yellow_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property($Cursor, "position", character_sel.position + Vector2(140, 135), 0.1)
	set_info(%Yellow, "Code Yellow:", Color.YELLOW, "a fighter specialized in laser weaponry and card generation")


func _on_violet_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property($Cursor, "position", character_sel.position + Vector2(240, 135), 0.1)
	set_info(%Violet, "Code Violet:", Color.BLUE_VIOLET, "a fighter specialized in high damage weaponry and turret deployment")


func set_info(button: Node, ch_name: String, color: Color, desc: String) -> void:
	char_pic.texture = button.texture_normal
	char_name.text = ch_name
	char_name.add_theme_color_override("font_color", color)
	char_desc.text = desc


func _on_blue_pressed() -> void:
	select("blue")


func _on_orange_pressed() -> void:
	select("orange")


func _on_red_pressed() -> void:
	select("red")


func _on_green_pressed() -> void:
	select("green")


func _on_yellow_pressed() -> void:
	select("yellow")


func _on_violet_pressed() -> void:
	select("violet")


func select(character: String) -> void:
	Audio.play_sfx(Audio.sfx_select)
	for row in %characterSelect.get_children():
		for button in row.get_children():
			button.set_deferred("disabled", true)
	
	gv.player_color = character
	emit_signal("player_selected")
