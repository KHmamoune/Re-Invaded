extends Node

var game_data_path: String = "res://Data/game_data.json"
var story_script_path: String = "res://Data/story_script.json"

func read_json(path: String) -> Dictionary:
	if FileAccess.file_exists(path):
		var data_file: FileAccess = FileAccess.open(path, FileAccess.READ)
		var parsed_result: Dictionary = JSON.parse_string(data_file.get_as_text())
		
		if parsed_result is Dictionary:
			return parsed_result
		else:
			return {}
		
	else:
		return {}
