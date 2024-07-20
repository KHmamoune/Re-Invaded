extends Area2D
class_name Enemy

signal dead

var hp: int
var is_dead: bool = false
var scrap: int
var status_effects: Dictionary = {}


@onready var drone: PackedScene = preload("res://Scenes/drone.tscn")


func _on_area_entered(area: Node) -> void:
	if "damage" in area:
		take_damage(area.damage)
		area.queue_free()


func shoot(bul: Node, _seconds: float, sfx: AudioStream = Audio.sfx_shoot) -> void:
	bul.set_collision_layer_value(5, true)
	if bul.wait_time > 0:
		var indicator: Node = preload("res://Scenes/indicator.tscn").instantiate()
		indicator.time = bul.wait_time
		indicator.type = bul.marker_type
		indicator.angle = bul.rotation_degrees
		indicator.position = bul.position
		get_parent().add_child(indicator)
		await get_tree().create_timer(bul.wait_time).timeout
	
	Audio.play_sfx(sfx)
	bul.z_index = -1
	get_parent().add_child(bul)


func take_damage(dmg: int) -> void:
	Audio.play_sfx(Audio.sfx_hit)
	hp -= dmg
	$hp.text = str(hp)
	
	if hp <= 0 and !is_dead:
		is_dead = true
		$Hurtbox.set_deferred("disabled", true)
		emit_signal("dead")
		queue_free()
