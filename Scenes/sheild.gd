extends Projectile

var type: String = "sheild"
var size: Vector2 = Vector2(1,1)
var time: float = 0


func _ready() -> void:
	$Timer.start(time)
	
	scale = size
	
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


func _on_attack_delay_timeout() -> void:
	attack[1].play(self)


func _on_area_entered(area: Node) -> void:
	area.queue_free()


func _on_timer_timeout() -> void:
	queue_free()
