extends Enemy


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
@onready var explosion: PackedScene = preload("res://Scenes/explosion.tscn")
@onready var bomb: PackedScene = preload("res://Scenes/bomb.tscn")
var awake: bool = false
var attacks: Array = [boss_at3]
var spining: bool = false
var passive_attack: Card.AttackPattren
var follow: bool = false
var bullet_speed_applied: bool = false
var self_repair_applied: bool = false


func _ready() -> void:
	$Animations.play("default")
	passive_attack = Card.AttackPattren.new(bullet, 2, 6, [0], 0.05, 800, [Vector2(20, 0), Vector2(-20, 0)], 800, 1)
	hp = 1000
	scrap = 500
	$hp.text = str(hp)


func _process(_delta: float) -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	
	if follow:
		if player.position.x - 5 > position.x:
			position.x += 5
		elif player.position.x + 5 < position.x:
			position.x -= 5


func start() -> void:
	awake = true
	$ShootTimer.start()


func _on_shoot_timer_timeout() -> void:
	follow = false
	$PassiveTimer.stop()
	$ShootTimer.stop()
	await get_tree().create_timer(0.1).timeout
	
	if hp <= 500 and !bullet_speed_applied:
		boss_at5()
		bullet_speed_applied = true
	
	if hp <= 200 and !self_repair_applied:
		boss_at6()
		self_repair_applied = true
	
	await attacks[randi_range(0, len(attacks)-1)].call()
	
	$ShootTimer.start()
	boss_at0()


func dash(distenation: float, time: float) -> void:
	Audio.play_sfx(Audio.sfx_dash)
	$AfterImageTimer.start()
	var t: Tween = create_tween()
	t.tween_property(self, "position:x", distenation, time)
	await t.finished
	$AfterImageTimer.stop()


func move(distenation: float, time: float) -> void:
	var t: Tween = create_tween()
	t.tween_property(self, "position:x", distenation, time)
	await t.finished


func _on_after_image_timer_timeout() -> void:
	var after_image_instance: Node = preload("res://Scenes/after_image.tscn").instantiate()
	after_image_instance.get_node("Sprite2D").texture = $Sprite2D.texture
	after_image_instance.get_node("Sprite2D").hframes = $Sprite2D.hframes
	after_image_instance.scale = $Sprite2D.scale
	after_image_instance.rotation = rotation
	after_image_instance.global_position = global_position
	get_parent().add_child(after_image_instance)


func boss_at0() -> void:
	$PassiveTimer.start()


func boss_at1() -> void:
	var attack1: Card.AttackPattren = Card.AttackPattren.new(explosion, 1, 1, [0], 0.1, 0, [Vector2.ZERO], 1200, 1)
	attack1.set_marker("marker", 1)
	
	for i in range(0, 6):
		attack1.set_abs_position([get_tree().get_first_node_in_group("player").position])
		attack1.play(self)
		await get_tree().create_timer(0.4).timeout
	
	await get_tree().create_timer(3).timeout


func boss_at2() -> void:
	var attack1: Card.AttackPattren = Card.AttackPattren.new(explosion, 3, 7, [0], 0.2, 0, [Vector2.ZERO], 1200, 1)
	attack1.set_marker("marker", 0.5)
	attack1.set_change_values([], [], [Vector2(0, 100), Vector2(0, 100), Vector2(0, 100)])
	await dash(575, 0.2)
	await get_tree().create_timer(0.2).timeout
	attack1.set_abs_position([position + Vector2(100, 0), position, position - Vector2(100, 0)])
	attack1.play(self)
	
	await get_tree().create_timer(1.5).timeout
	await dash(750, 0.2)
	await get_tree().create_timer(0.2).timeout
	attack1.set_abs_position([position + Vector2(100, 0), position, position - Vector2(100, 0)])
	attack1.play(self)
	
	await get_tree().create_timer(1.5).timeout
	await dash(400, 0.2)
	await get_tree().create_timer(0.2).timeout
	attack1.set_abs_position([position + Vector2(100, 0), position, position - Vector2(100, 0)])
	attack1.play(self)
	
	await get_tree().create_timer(3).timeout


func boss_at3() -> void:
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bomb, 2, 1, [0], 1, 1000, [Vector2.ZERO], 1200, 1)
	attack1.set_tweens([], [{"delay": 0.5, "value": 0, "dur": 0.25}])
	attack1.set_tweens([], [{"delay": 0.5, "value": 0, "dur": 0.25}])
	attack1.set_bomb_properties(1, Vector2(1, 1), 1)
	
	for i in range(0, 6):
		attack1.set_abs_position([Vector2(randi_range(250, 575), -20), Vector2(randi_range(575, 900), -20)])
		attack1.play(self)
		await get_tree().create_timer(1).timeout
	
	await get_tree().create_timer(1).timeout


func boss_at4() -> void:
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 50, [0], 0.1, 400, [Vector2.ZERO], 1200, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 20, [135, 225], 0.2, 300, [Vector2.ZERO], 1200, 1)
	
	attack1.set_tweens([
		{"delay": 0, "value": 225, "dur": 0.2}, 
		{"delay": 0.2, "value": 135, "dur": 0.2},
		{"delay": 0.4, "value": 225, "dur": 0.2}
		])
	attack1.set_tweens([
		{"delay": 0, "value": 135, "dur": 0.2}, 
		{"delay": 0.2, "value": 225, "dur": 0.2},
		{"delay": 0.4, "value": 135, "dur": 0.2}
		])
	
	attack2.set_tweens([
		{"delay": 0, "value": 170, "dur": 0.5},
		])
	attack2.set_tweens([
		{"delay": 0, "value": 550, "dur": 0.5},
		])
	attack2.set_change_values([-20, 20])
	
	attack1.play(self)
	await get_tree().create_timer(2).timeout
	attack2.play(self)
	await get_tree().create_timer(5).timeout


func boss_at5() -> void:
	StatusEffects.apply_bullet_speed_boost(self)
	await get_tree().create_timer(0.5).timeout


func boss_at6() -> void:
	StatusEffects.apply_self_repair(self, 2, -10)
	await get_tree().create_timer(0.5).timeout


func update_status_bar() -> void:
	$StatusEffectsBar.update_status_effects(status_effects)


func _on_passive_timer_timeout() -> void:
	dash(get_tree().get_first_node_in_group("player").position.x, 0.2)
	await get_tree().create_timer(0.5).timeout
	passive_attack.play(self)
