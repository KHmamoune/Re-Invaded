extends Projectile


var type: String = "laser"
var duration: float = 0.1


func _ready() -> void:
	if len(angle_tweens) > 0:
		execute_angle_tweens()
	
	if len(position_tweens) > 0:
		execute_position_tweens()
	
	var tween: Tween = create_tween()
	var tween2: Tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(0.5,5), 0.1)
	tween.tween_property($Hitbox, "scale", Vector2(0.7,1), 0.1)
	tween2.tween_property($Sprite2D, "scale", Vector2(0,5), 0.1).set_delay(duration)
	tween2.tween_property($Hitbox, "scale", Vector2(0,1), 0.1)
	tween2.tween_callback(queue_free)
	
	if target != null:
		rotation = global_position.angle_to_point(target.global_position) + deg_to_rad(90)


func execute_angle_tweens() -> void:
	var t: Tween = create_tween().set_loops(1)
	for tween: Dictionary in angle_tweens:
		t.tween_interval(tween["delay"])
		t.tween_property(self, "rotation_degrees", tween["value"], tween["dur"])


func _on_area_entered(area: Node) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
