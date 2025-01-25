extends Node2D


var type: String = ""
var time: float = 0
var angle: float = 0
var mute: bool = true


func _ready() -> void:
	rotation_degrees = angle
	
	if not mute:
		Audio.play_sfx(Audio.sfx_alert)
	
	if type == "line":
		$Line2D.visible = true
		await get_tree().create_timer(time).timeout
		$Line2D.visible = false
	elif type == "marker":
		$Animations.play("fade_in")
		await get_tree().create_timer(time).timeout
	
	queue_free()
