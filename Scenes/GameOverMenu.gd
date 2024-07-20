extends Control


@onready var GameOverMenu: Node = $"../"


func _ready() -> void:
	%Restart.grab_focus()


func _on_restart_pressed() -> void:
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_main_pressed() -> void:
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_player_dead() -> void:
	GameOverMenu.show()
