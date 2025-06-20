extends Projectile

var type: String = "explosion"
var rad: Vector2 = Vector2(1, 1)


func _ready() -> void:
	$Sprite2D.scale = rad + Vector2(4, 4)
	$HitBox.scale = rad
	$Animations.play("explode")
	Audio.play_sfx(Audio.sfx_explosion)
	
	for i in get_overlapping_areas():
		if i.has_method("take_damage"):
			i.take_damage(damage)
	
	await $Animations.animation_finished
	queue_free()


func _on_area_entered(area: Node) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
