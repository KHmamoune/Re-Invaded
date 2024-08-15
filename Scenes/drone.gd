extends Projectile

var type: String = "drone"
var time: float = 0


func _ready() -> void:
	$Sprite2D.scale = sprite_size
	$Hitbox.scale = hitbox_size
	$Sprite2D.hframes = frames
	$Sprite2D.texture = sprite
	
	$Timer.start(time)
	
	if target != null:
		rotation_degrees = aim()
	
	if len(speed_tweens) > 0:
		execute_speed_tweens()
	
	if len(angle_tweens) > 0:
		execute_angle_tweens()
	
	if len(position_tweens) > 0:
		execute_position_tweens()
	
	if len(attack) > 0:
		get_tree().create_timer(attack[0]).connect("timeout", Callable(_on_attack_delay_timeout))


func _process(delta: float) -> void:
	var direction: Vector2 = Vector2.UP.rotated(rotation)
	position += direction * speed * delta
	traveled += speed * delta
	
	if look == "player":
		look_at(get_tree().get_nodes_in_group("player")[0].global_position)
		rotation_degrees -= 90
	elif look == "enemy":
		if get_closest() != null:
			look_at(get_closest().global_position)
			rotation_degrees += 90
	
	if bouncy:
		if global_position.x >= 925 or global_position.x <= 225:
			rotation_degrees = -rotation_degrees
	
	if traveled > move_range:
		queue_free()


func _on_attack_delay_timeout() -> void:
	attack[1].play(self)


func _on_timer_timeout() -> void:
	queue_free()


func _on_area_entered(area: Node) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
