extends Area2D

var damage: int = 10
var type: String = "explosion"
var rad: Vector2 = Vector2(1, 1)


func _ready() -> void:
	$Sprite2D.scale = rad
	$HitBox.scale = rad
	$Animations.play("explode")
	
	for i in get_overlapping_areas():
		if i.has_method("take_damage"):
			i.take_damage(damage)
	
	await $Animations.animation_finished
	queue_free()


func _on_area_entered(area: Node) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
