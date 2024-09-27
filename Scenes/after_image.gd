extends Node2D


func _ready() -> void:
	var t: Tween = create_tween()
	t.tween_property($Sprite2D, "modulate:a", 0, 0.2)
	t.tween_callback(Callable(queue_free))
