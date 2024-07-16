extends Control


@onready var blue_button: Node = $CanvasLayer/Menus/PlayerSelect/MarginContainer/characterSelect/Row1/Blue
@onready var cursor: Node = $CanvasLayer/Menus/PlayerSelect/Cursor/AnimationPlayer

func _ready() -> void:
	gv.current_scene = self
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
	create_tween().tween_property(%texture, "position:y", 132, 0.2).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property(%texture, "modulate", Color.BLUE, 0.2)


func _on_options_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property(%texture, "position:y", %Options.position.y + 12, 0.2).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property(%texture, "modulate", Color.VIOLET, 0.2)


func _on_extras_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property(%texture, "position:y", %Extras.position.y + 12, 0.2).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property(%texture, "modulate", Color.GREEN, 0.2)


func _on_quit_focus_entered() -> void:
	Audio.play_sfx(Audio.sfx_switch)
	create_tween().tween_property(%texture, "position:y", %Quit.position.y + 12, 0.2).set_trans(Tween.TRANS_CUBIC)
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
