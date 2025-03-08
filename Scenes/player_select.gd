extends Control


signal move_main
signal player_selected

@onready var character_sel: Node = $MarginContainer/characterSelect
@onready var char_pic: Node = $MarginContainer/Panel/characterInfo/HBoxContainer/TextureRect
@onready var char_name: Node = $MarginContainer/Panel/characterInfo/HBoxContainer/VBoxContainer/description/Label
@onready var char_desc: Node = $MarginContainer/Panel/characterInfo/HBoxContainer/VBoxContainer/description/Label2
@onready var char_stats: Node = $MarginContainer/Panel/characterInfo/HBoxContainer/VBoxContainer/stats/StatsContainer


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		emit_signal("move_main")


func _on_blue_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property($Cursor, "position", character_sel.position + Vector2(40, 35), 0.1)
	set_info(%Blue, "Code Blue:", Color.BLUE, "a fighter specialized in rapid fire weaponry and enhancement technology", "blue")


func _on_orange_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property($Cursor, "position", character_sel.position + Vector2(140, 35), 0.1)
	set_info(%Orange, "Code Orange:", Color.ORANGE, "a fighter specialized in explosive weaponry and flame throwers", "orange")


func _on_red_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property($Cursor, "position", character_sel.position + Vector2(240, 35), 0.1)
	set_info(%Red, "Code Red:", Color.RED, "a fighter specialized in wide range weaponry and trade enhancements", "red")


func _on_green_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property($Cursor, "position", character_sel.position + Vector2(40, 135), 0.1)
	set_info(%Green, "Code Green:", Color.GREEN, "a fighter specialized in auto aim weaponry and defensive technology", "green")


func _on_yellow_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property($Cursor, "position", character_sel.position + Vector2(140, 135), 0.1)
	set_info(%Yellow, "Code Yellow:", Color.YELLOW, "a fighter specialized in laser weaponry and card generation", "yellow")


func _on_violet_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property($Cursor, "position", character_sel.position + Vector2(240, 135), 0.1)
	set_info(%Violet, "Code Violet:", Color.BLUE_VIOLET, "a fighter specialized in high damage weaponry and turret deployment", "violet")


func set_info(button: Node, ch_name: String, color: Color, desc: String, code: String) -> void:
	char_pic.texture = button.texture_normal
	char_name.text = ch_name
	char_name.add_theme_color_override("font_color", color)
	char_desc.text = desc
	char_stats.get_node("HP").text = "Max HP: " + str(gv.character_stats[code]["hp"])
	char_stats.get_node("Speed").text = "Speed: " + str(gv.character_stats[code]["speed"])
	char_stats.get_node("Energy").text = "Max Energy: " + str(gv.character_stats[code]["energy"])
	char_stats.get_node("GenModifier").text = "Energy Generation: " + str(gv.character_stats[code]["gen_modifier"])


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
