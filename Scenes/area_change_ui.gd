extends Control


signal act_chosen(name: String)


var button: PackedScene = preload("res://Scenes/act_change_button.tscn")
var data: Array


func _ready() -> void:
	update_buttons(data)
	create_tween().tween_property(self, "modulate:a", 255, 0.5)
	%Buttons.get_child(0).grab_focus()


func update_buttons(areas: Array) -> void:
	for area: Dictionary in areas:
		var inst: Node = button.instantiate()
		inst.get_node("Text").text = area["name"]
		inst.get_node("Text").modulate = Color.GREEN
		inst.get_node("Image").texture = load(area["image"])
		inst.modulate = Color("4b4b4b")
		inst.connect("focus_entered", Callable(_on_focus_entered).bind(inst))
		inst.connect("focus_exited", Callable(_on_focus_exited).bind(inst))
		inst.connect("pressed", Callable(_on_button_pressed).bind(area["name"]))
		%Buttons.add_child(inst)


func _on_focus_entered(inst: Node) -> void:
	var t: Tween = create_tween()
	t.tween_property(inst, "scale", Vector2(1.2, 1.2), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	t.parallel().tween_property(inst, "modulate", Color.WHITE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _on_focus_exited(inst: Node) -> void:
	var t: Tween = create_tween()
	t.tween_property(inst, "scale", Vector2(1, 1), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	t.parallel().tween_property(inst, "modulate", Color("4b4b4b"), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _on_button_pressed(act_name: String) -> void:
	act_chosen.emit(act_name)
