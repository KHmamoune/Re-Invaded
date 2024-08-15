extends Enemy


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
var awake: bool = false
var attacks: Array = [boss_at1, boss_at2, boss_at3]
var i: int = 0
var spining: bool = false


func _ready() -> void:
	hp = 200
	scrap = 200
	$hp.text = str(hp)


func _process(_delta: float) -> void:
	if spining:
		$Sprite.rotation_degrees += 20


func start() -> void:
	$Animations.play("boot_up")
	await $Animations.animation_finished
	$Animations.play("idle")
	awake = true
	$ShootTimer.start()


func _on_shoot_timer_timeout() -> void:
	$ShootTimer.stop()
	
	await attacks[i].call()
	
	i += 1
	if i >= len(attacks):
		i = 0
	
	$ShootTimer.start()


func boss_at1() -> void:
	var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 5, 20, [0, 72, 144, 216, 288], 0.1, 500, [Vector2.ZERO], 1200, 1)
	attack.set_tweens([], [{"delay": 0, "value": 50, "dur": 0.1}, {"delay": 0.6, "value": 500, "dur": 0.5}])
	attack.set_tweens([], [{"delay": 0, "value": 50, "dur": 0.1}, {"delay": 0.6, "value": 500, "dur": 0.5}])
	attack.set_tweens([], [{"delay": 0, "value": 50, "dur": 0.1}, {"delay": 0.6, "value": 500, "dur": 0.5}])
	attack.set_tweens([], [{"delay": 0, "value": 50, "dur": 0.1}, {"delay": 0.6, "value": 500, "dur": 0.5}])
	attack.set_tweens([], [{"delay": 0, "value": 50, "dur": 0.1}, {"delay": 0.6, "value": 500, "dur": 0.5}])
	attack.set_change_values([-15, -15, -15, -15, -15])
	
	spining = true
	var pos_tween: Tween = create_tween()
	pos_tween.tween_property(self, "position", Vector2(100, 100), 1)
	await pos_tween.finished
	attack.play(self)
	pos_tween = create_tween()
	pos_tween.tween_property(self, "position", Vector2(1100, 300), 2)
	await pos_tween.finished
	attack.set_change_values([15, 15, 15, 15, 15])
	position = Vector2(1100, 100)
	attack.play(self)
	pos_tween = create_tween()
	pos_tween.tween_property(self, "position", Vector2(100, 300), 2)
	await pos_tween.finished
	position = Vector2(get_tree().get_nodes_in_group("player")[0].position.x , 800)
	$Indicator.visible = true
	Audio.play_sfx(Audio.sfx_alert)
	await get_tree().create_timer(0.4).timeout
	$Indicator.visible = false
	pos_tween = create_tween()
	pos_tween.tween_property(self, "position:y", -100, 2)
	await get_tree().create_timer(0.5).timeout
	attack.play(self)
	await pos_tween.finished
	reset_position()


func boss_at2() -> void:
	var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 10, 25, [0, 36, 72, 98, 144, 180, 216, 252, 288, 324], 0.2, 400, [Vector2.ZERO], 1200, 1)
	attack.set_aim("", 20)
	var circle_tween: Tween = create_tween()
	var circle_tween2: Tween = create_tween()
	spining = true
	circle_tween.set_loops(3)
	circle_tween2.set_loops(3)
	circle_tween.tween_property(self, "position:y", 200, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	circle_tween.tween_property(self, "position:y", 150, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	circle_tween.tween_property(self, "position:y", 100, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	circle_tween.tween_property(self, "position:y", 150, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	circle_tween2.tween_property(self, "position:x", 610, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	circle_tween2.tween_property(self, "position:x", 510, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	attack.play(self)
	await circle_tween.finished
	await circle_tween2.finished
	reset_position()


func boss_at3() -> void:
	var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 4, 50, [45, 135, 225, 315], 0.1, 250, [Vector2.ZERO], 2000, 1)
	attack.set_properties(true)
	attack.set_change_values([23, -23, 23, -23])
	spining = true
	attack.play(self)
	await get_tree().create_timer(6).timeout


func hit_flash() -> void:
	$Sprite/Sprite2D.material.set_shader_parameter("flash_modifier", 1)
	$Sprite/Sprite2D2.material.set_shader_parameter("flash_modifier", 1)
	await get_tree().create_timer(0.02).timeout
	$Sprite/Sprite2D.material.set_shader_parameter("flash_modifier", 0)
	$Sprite/Sprite2D2.material.set_shader_parameter("flash_modifier", 0)


func reset_position() -> void:
	var pos_tween: Tween = create_tween()
	pos_tween.tween_property(self, "position", Vector2(575, 150), 1)
	await pos_tween.finished
	$Sprite.rotation_degrees = 0
	spining = false


func _on_move_timer_timeout() -> void:
	var rand_mov: Vector2 = Vector2(randi_range(300, 850), randi_range(200, 300))
	var t: Tween = create_tween()
	t.tween_property(self, "position", rand_mov, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func update_status_bar() -> void:
	$StatusEffectsBar.update_status_effects(status_effects)
