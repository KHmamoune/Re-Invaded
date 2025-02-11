extends HBoxContainer


var text: String = ""
var image: String = ""

func _ready() -> void:
	$Label.text = text
	if image != "":
		$TextureRect.texture = gv.status_icons[image]
