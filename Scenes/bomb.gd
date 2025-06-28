extends Projectile

var explosion: Node = preload("res://Scenes/explosion.tscn").instantiate()
var type: String = "bomb"
var rad: Vector2 = Vector2(1, 1)
var time: float = 0
var explosion_damage: int = 10
var flashing: bool = false


func _ready() -> void:
	$Timer.wait_time = time
	$Timer.start()
	
	if after_image_interval > 0:
		play_after_image()
	
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
	
	if bouncy:
		if global_position.x >= 925 or global_position.x <= 225:
			rotation_degrees = -rotation_degrees
	
	if traveled > move_range:
		queue_free()
	
	if $Timer.time_left <= 0.4 and not flashing:
		flashing = true
		$Animations.play("flash")


func _on_attack_delay_timeout() -> void:
	attack[1].play(self)


func _on_area_entered(area: Node) -> void:
	explode()
	queue_free()
	
	if area.has_method("take_damage"):
		area.take_damage(damage)


func explode() -> void:
	if !is_dead:
		is_dead = true
		explosion.rad = rad
		explosion.position = position
		explosion.damage = explosion_damage
		explosion.set_collision_layer_value(5, get_collision_layer_value(5))
		explosion.set_collision_layer_value(3, get_collision_layer_value(3))
		gv.current_scene.call_deferred("add_child", explosion)
		queue_free()


func _on_timer_timeout() -> void:
	explode()
	queue_free()
