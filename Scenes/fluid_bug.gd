extends Enemy


var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 5, [180], 0.1, 1000, [Vector2(0, 20)], 800, 1)
var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 5, 1, [80, 40, 0, -40, -80], 0.1, 400, [Vector2.ZERO], 800, 1)


func _ready() -> void:
	color = Color.CYAN
	set_up_hp(30, Vector2(0, 50))
	set_up_status_effects(Vector2(-15, 65))
	scrap = 10
	
	attack1.set_sprite_preset(gv.icicle_bullet_preset, Color.WHITE)
	attack2.set_sprite_preset(gv.icicle_bullet_preset, Color.WHITE)
	attack2.set_after_image(0.01, 0.03)
	attack2.set_tweens([
		{"delay": 0.8, "value": 180, "dur": 0.5}
	], [
		{"delay": 0, "value": 0, "dur": 0.6},
		{"delay": 1, "value": 1000, "dur": 2}
	])
	attack2.set_tweens([
		{"delay": 0.8, "value": 180, "dur": 0.5}
	], [
		{"delay": 0, "value": 0, "dur": 0.6},
		{"delay": 1, "value": 1000, "dur": 2}
	])
	attack2.set_tweens([
		{"delay": 0.8, "value": 180, "dur": 0.5}
	], [
		{"delay": 0, "value": 0, "dur": 0.6},
		{"delay": 1, "value": 1000, "dur": 2}
	])
	attack2.set_tweens([
		{"delay": 0.8, "value": -180, "dur": 0.5}
	], [
		{"delay": 0, "value": 0, "dur": 0.6},
		{"delay": 1, "value": 1000, "dur": 2}
	])
	attack2.set_tweens([
		{"delay": 0.8, "value": -180, "dur": 0.5}
	], [
		{"delay": 0, "value": 0, "dur": 0.6},
		{"delay": 1, "value": 1000, "dur": 2}
	])


func start() -> void:
	$Animations.play("idle")
	$MoveTimer.start()
	$ShootTimer.start()


func take_damage(dmg: int, area: Node = null) -> void:
	Audio.play_sfx(Audio.sfx_hit)
	hp -= dmg
	hp_node.get_child(0).text = str(hp)
	
	if hp <= 0 and !is_dead:
		attack2.play(self)
		is_dead = true
		$Hurtbox.set_deferred("disabled", true)
		
		if area != null:
			if len(area.on_kill_effects) != 0:
				for effect: Card.CardStats in area.on_kill_effects:
					var player: Node = get_tree().get_first_node_in_group("player")
					effect.play(player, self)
		
		dead.emit(scrap)
		hp_node.queue_free()
		status_node.queue_free()
		Audio.play_sfx(Audio.sfx_enemy_death_explosion)
		queue_free()


func _on_move_timer_timeout() -> void:
	var rand_mov: Vector2 = Vector2(randi_range(300, 850), randi_range(200, 300))
	var t: Tween = create_tween()
	t.tween_property(self, "position", rand_mov, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func _on_shoot_timer_timeout() -> void:
	$MoveTimer.stop()
	$Animations.play("attack")
	
	await get_tree().create_timer(0.5).timeout
	attack1.play(self)
	await get_tree().create_timer(1.5).timeout
	
	$Animations.play_backwards("attack")
	
	await get_tree().create_timer(0.5).timeout
	$Animations.play("idle")
	$MoveTimer.start()
	$ShootTimer.start()
