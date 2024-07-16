extends Control


@onready var PauseMenu: Node = $"../"
var paused: bool = false
var prev_focus: Node


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause()


func pause() -> void:
	if !paused:
		prev_focus = get_viewport().gui_get_focus_owner()
		%Resume.grab_focus()
		PauseMenu.show()
		Engine.time_scale = 0
		get_tree().paused = true
	else:
		if prev_focus != null:
			prev_focus.grab_focus()
		PauseMenu.hide()
		Engine.time_scale = 1
		get_tree().paused = false
		
	paused = !paused

func _on_resume_pressed() -> void:
	pause()


func _on_main_pressed() -> void:
	prev_focus = null
	pause()
	gv.cards = []
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
