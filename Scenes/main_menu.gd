extends Control


@onready var blue_button: Node = $CanvasLayer/Menus/PlayerSelect/MarginContainer/characterSelect/Row1/Blue
@onready var cursor: Node = $CanvasLayer/Menus/PlayerSelect/Cursor/AnimationPlayer
var menu_visible: bool = false

func _ready() -> void:
	gv.current_scene = self
	
	%Title.pivot_offset = Vector2(249, 55.5)
	var t: Tween = create_tween()
	t.set_loops()
	t.tween_property(%Title, "scale", Vector2(0.95, 0.95), 2)
	t.tween_property(%Title, "scale", Vector2.ONE, 2)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot1"):
		if menu_visible == false:
			menu_visible = true
			var t1: Tween = create_tween()
			%BG1.create_tween().tween_property(%BG1, "self_modulate", Color.WEB_GREEN, 1)
			%BG2.create_tween().tween_property(%BG2, "self_modulate", Color.WEB_GREEN, 1)
			t1.tween_property(%StartText, "modulate:a", 0, 0.5)
			t1.tween_property(%Title, "position:y", %Title.position.y - 100, 1). set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			t1.tween_property(%MenuButtons, "modulate:a", 1, 1)
			await t1.finished
			%Play.grab_focus()


func _on_play_pressed() -> void:
	Audio.play_sfx(Audio.sfx_select)
	var tween: Tween = create_tween()
	tween.tween_property($CanvasLayer/Menus, "position:x", -1152, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	blue_button.grab_focus()
	cursor.play("move")


func _on_quit_pressed() -> void:
	Audio.play_sfx(Audio.sfx_select)
	get_tree().quit()


func _on_play_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property(%texture, "position:y", %Play.position.y + 15, 0.2).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property(%texture, "modulate", Color.BLUE, 0.2)


func _on_options_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property(%texture, "position:y", %Options.position.y + 15, 0.2).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property(%texture, "modulate", Color.VIOLET, 0.2)


func _on_extras_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property(%texture, "position:y", %Extras.position.y + 15, 0.2).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property(%texture, "modulate", Color.GREEN, 0.2)


func _on_quit_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property(%texture, "position:y", %Quit.position.y + 15, 0.2).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property(%texture, "modulate", Color.GRAY, 0.2)


func _on_player_select_move_main() -> void:
	var tween: Tween = create_tween()
	tween.tween_property($CanvasLayer/Menus, "position:x", 0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	%Play.grab_focus()
	cursor.stop()


func _on_player_select_player_selected() -> void:
	$Animations.play("slide_trans")
	await $Animations.animation_finished
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
