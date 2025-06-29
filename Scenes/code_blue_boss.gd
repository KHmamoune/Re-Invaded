extends Enemy


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
var awake: bool = false
var attacks: Array = [boss_at1, boss_at2, boss_at3, boss_at4]
var spining: bool = false
var passive_attack: Card.AttackPattren
var follow: bool = false
var bullet_speed_applied: bool = false
var self_repair_applied: bool = false


func _ready() -> void:
	$Animations.play("default")
	passive_attack = Card.AttackPattren.new(bullet, 2, 6, [0], 0.05, 800, [Vector2(20, 0), Vector2(-20, 0)], 800, 1)
	set_up_hp(1000, Vector2(0, 50))
	set_up_status_effects(Vector2(-15, 65))
	scrap = 500


func _process(_delta: float) -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	
	if follow:
		if player.position.x - 1.5 > position.x:
			position.x += 0.5
		elif player.position.x + 1.5 < position.x:
			position.x -= 0.5


func start() -> void:
	awake = true
	$Animations.play("default")
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


func boss_at0() -> void:
	$PassiveTimer.start()
	follow = true


func boss_at1() -> void:
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 20, [90, -90], 0.05, 400, [Vector2.ZERO], 1200, 1)
	attack1.set_change_values([-9, 9], [-10, -10])
	var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 10, [70, -70], 0.1, 500, [Vector2.ZERO], 2000, 1)
	attack2.set_properties(true)
	
	await dash(500, 0.2)
	attack1.play(self)
	await get_tree().create_timer(1.2).timeout
	await dash(650, 0.2)
	attack1.play(self)
	await get_tree().create_timer(1.2).timeout
	await dash(400, 0.2)
	attack1.play(self)
	await get_tree().create_timer(1.2).timeout
	await dash(750, 0.2)
	attack1.play(self)
	await get_tree().create_timer(1.2).timeout
	await dash(575, 0.2)
	attack2.play(self)
	await get_tree().create_timer(1).timeout


func boss_at2() -> void:
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 10, [0], 0.2, 500, [Vector2.ZERO], 1200, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 30, [180], 0.01, 400, [Vector2.ZERO], 1200, 1)
	attack2.set_change_values([12])
	attack2.set_tweens([{"delay": 0, "value": 90, "dur": 12}])
	
	var attack3: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 30, [180], 0.01, 400, [Vector2.ZERO], 1200, 1)
	attack3.set_change_values([-12])
	attack3.set_tweens([{"delay": 0, "value": 360, "dur": 12}])
	
	await dash(250, 0.2)
	await get_tree().create_timer(0.5).timeout
	attack1.play(self)
	await move(900, 2)
	attack2.play(self)
	await get_tree().create_timer(1).timeout
	attack1.play(self)
	await move(250, 2)
	attack3.play(self)
	await get_tree().create_timer(1).timeout


func boss_at3() -> void:
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 20, [0], 0.05, 800, [Vector2.ZERO], 1200, 1)
	attack1.set_aim("", 30)
	
	for j in range(0, 3):
		await dash(randi_range(250, 900), 0.3)
		attack1.play(self)
		await get_tree().create_timer(1.5).timeout
	
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


func _on_passive_timer_timeout() -> void:
	passive_attack.play(self)
