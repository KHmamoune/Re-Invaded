extends Projectile


var type: String = "bullet"


func _ready() -> void:
	$Sprite2D.scale = sprite_size
	$Hitbox.scale = hitbox_size
	$Sprite2D.hframes = frames
	$Sprite2D.texture = sprite
	$Sprite2D.modulate = bullet_color
	
	if after_image_interval > 0:
		play_after_image()
	
	if frames > 1:
		var tween: Tween = create_tween()
		tween.set_loops()
		tween.tween_property($Sprite2D, "frame", frames-1, anm_speed)
		tween.tween_property($Sprite2D, "frame", 0, 0)
	
	if target != null:
		rotation_degrees = aim()
	
	if len(speed_tweens) > 0:
		execute_speed_tweens()
	
	if len(angle_tweens) > 0:
		execute_angle_tweens()
	
	if len(position_tweens) > 0:
		execute_position_tweens()
	
	if len(size_tweens) > 0:
		execute_size_tweens()
	
	if len(attack) > 0:
		get_tree().create_timer(attack[0]).connect("timeout", Callable(_on_attack_delay_timeout))
	
	if fade_in_delay != 0:
		fade_in(fade_in_delay, fade_in_duration)
	
	if look_delay > 0:
		await get_tree().create_timer(look_delay).timeout
	
	looking = true
	
	if look_duration > 0:
		await get_tree().create_timer(look_duration).timeout
		looking = false


func _process(delta: float) -> void:
	var direction: Vector2 = Vector2.UP.rotated(rotation)
	position += direction * speed * delta
	traveled += speed * delta
	
	if bouncy:
		if global_position.x >= 925 or global_position.x <= 225:
			rotation_degrees = -rotation_degrees
	
	if looking:
		if look == "player":
			look_at(get_tree().get_nodes_in_group("player")[0].global_position)
			rotation_degrees += 90
		elif look == "enemy":
			if get_closest("enemy") != null:
				look_at(get_closest("enemy").global_position)
				rotation_degrees += 90
		
	if traveled > move_range:
		var t: Tween = create_tween()
		t.tween_property(self, "modulate:a", 0, 0.2)
		t.tween_callback(Callable(queue_free))


func _on_attack_delay_timeout() -> void:
	attack[1].play(self)
	if attack[2]:
		queue_free()


func _on_area_entered(area: Node) -> void:
	if not piercing:
		queue_free()
	
	if area.has_method("take_damage"):
		for effect: Card.StatusAffliction in on_hit_effects:
			effect.play(area)
		
		area.take_damage(damage)
	elif area.has_method("lose_health"):
		for effect: Card.StatusAffliction in on_hit_effects:
			effect.play(area)
		
		area.lose_health()
