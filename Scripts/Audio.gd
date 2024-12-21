extends Node


var sfx_shoot: AudioStream = preload("res://SFX/shoot.wav")
var sfx_dash: AudioStream = preload("res://SFX/dash.wav")
var sfx_hit: AudioStream = preload("res://SFX/hit.wav")
var sfx_explosion: AudioStream = preload("res://SFX/explosion.wav")
var sfx_flash: AudioStream = preload("res://SFX/flash.wav")
var sfx_damage: AudioStream = preload("res://SFX/damage.wav")
var sfx_select: AudioStream = preload("res://SFX/select.wav")
var sfx_switch: AudioStream = preload("res://SFX/switch.wav")
var sfx_blast_off: AudioStream = preload("res://SFX/blast_off.wav")
var sfx_alert: AudioStream = preload("res://SFX/alert.wav")


func play_sfx(sfx: AudioStream) -> void:
	if sfx == null:
		return
	
	var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	player.stream = sfx
	gv.current_scene.add_child(player)
	player.play()
	player.finished.connect(func() -> void: player.queue_free())
