extends Enemy


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
var awake: bool = false
var attacks: Array = [boss_at5]
var spining: bool = false
var passive_attack1: Card.AttackPattren
var passive_attack2: Card.AttackPattren
var passive_attack3: Card.AttackPattren
var follow: bool = false
var bullet_speed_applied: bool = false
var self_repair_applied: bool = false


func _ready() -> void:
	$Animations.play("default")
	passive_attack1 = Card.AttackPattren.new(bullet, 2, 1, [-3, 3], 0.05, 750, [Vector2(10, 0), Vector2(-10, 0)], 800, 1)
	passive_attack2 = Card.AttackPattren.new(bullet, 2, 1, [-2, 2], 0.05, 775, [Vector2(5, 0), Vector2(-5, 0)], 800, 1)
	passive_attack3 = Card.AttackPattren.new(bullet, 2, 1, [-1, 1], 0.05, 800, [Vector2(0, 0), Vector2(0, 0)], 800, 1)
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
	print("started")
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
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 4, 1, [60,50,40,30], 0.1, 400, [Vector2.ZERO], 1200, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 5, 1, [70,60,45,30,20], 0.1, 400, [Vector2.ZERO], 1200, 1)
	var attack3: Card.AttackPattren = Card.AttackPattren.new(bullet, 4, 1, [-60,-50,-40,-30], 0.1, 400, [Vector2.ZERO], 1200, 1)
	var attack4: Card.AttackPattren = Card.AttackPattren.new(bullet, 5, 1, [-70,-60,-45,-30,-20], 0.1, 400, [Vector2.ZERO], 1200, 1)
	attack1.set_properties(true)
	attack2.set_properties(true)
	attack3.set_properties(true)
	attack4.set_properties(true)
	
	await dash(350, 0.2)
	
	for i in range(0, 3):
		attack1.play(self)
		await get_tree().create_timer(0.1).timeout
		attack2.play(self)
		await get_tree().create_timer(0.1).timeout
	
	await dash(800, 0.2)
	
	for i in range(0, 3):
		attack3.play(self)
		await get_tree().create_timer(0.1).timeout
		attack4.play(self)
		await get_tree().create_timer(0.1).timeout
	
	await get_tree().create_timer(2).timeout


func boss_at2() -> void:
	var arr1: Array = []
	var arr2: Array = []
	
	for i in range(0, 20):
		arr1.append(i * (360 / 20))
		arr2.append(10)
	
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 20, 15, arr1, 0.2, 400, [Vector2.ZERO], 1200, 1)
	attack1.set_change_values(arr2)
	
	await dash(575, 0.2)
	
	attack1.play(self)
	
	await get_tree().create_timer(2).timeout


func boss_at3() -> void:
	var rand_mod: int = randi_range(0, 9)
	var arr1: Array = []
	var arr2: Array = []
	var arr3: Array = []
	var arr4: Array = []
	
	for i in range(0, 10):
		arr1.append(i * (360 / 10) + 9 + rand_mod)
		arr2.append(i * (360 / 10) + 27 + rand_mod)
		arr3.append(i * (360 / 10) + 18 + rand_mod)
		arr4.append(i * (360 / 10) + rand_mod)
	
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 10, 10, arr1, 0.1, 300, [Vector2.ZERO], 1200, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 10, 10, arr2, 0.1, 300, [Vector2.ZERO], 1200, 1)
	var attack3: Card.AttackPattren = Card.AttackPattren.new(bullet, 10, 10, arr3, 0.1, 300, [Vector2.ZERO], 1200, 1)
	var attack4: Card.AttackPattren = Card.AttackPattren.new(bullet, 10, 10, arr4, 0.1, 300, [Vector2.ZERO], 1200, 1)
	var attack5: Card.AttackPattren = Card.AttackPattren.new(bullet, 20, 1, arr1 + arr2, 0.1, 400, [Vector2.ZERO], 1200, 1)
	var attack6: Card.AttackPattren = Card.AttackPattren.new(bullet, 20, 1, arr3 + arr4, 0.1, 400, [Vector2.ZERO], 1200, 1)
	
	for i in range(0, 10):
		attack1.set_tweens([
			{"delay": 0, "value": arr1[i] + 180 - 45, "dur": 0.2}, 
			{"delay": 0.2, "value": arr1[i] + 180 + 45, "dur": 0.2},
			{"delay": 0.4, "value": arr1[i] + 180 - 45, "dur": 0.2},
			{"delay": 0.6, "value": arr1[i] + 180 + 45, "dur": 0.2},
			{"delay": 0.8, "value": arr1[i] + 180 - 45, "dur": 0.2},
			{"delay": 1, "value": arr1[i] + 180 + 45, "dur": 0.2}
			])
		attack2.set_tweens([
			{"delay": 0, "value": arr2[i] + 180 + 45, "dur": 0.2}, 
			{"delay": 0.2, "value": arr2[i] + 180 - 45, "dur": 0.2},
			{"delay": 0.4, "value": arr2[i] + 180 + 45, "dur": 0.2},
			{"delay": 0.6, "value": arr2[i] + 180 - 45, "dur": 0.2},
			{"delay": 0.8, "value": arr2[i] + 180 + 45, "dur": 0.2},
			{"delay": 1, "value": arr2[i] + 180 - 45, "dur": 0.2}
			])
		attack3.set_tweens([
			{"delay": 0, "value": arr3[i] + 180 + 45, "dur": 0.2}, 
			{"delay": 0.2, "value": arr3[i] + 180 - 45, "dur": 0.2},
			{"delay": 0.4, "value": arr3[i] + 180 + 45, "dur": 0.2},
			{"delay": 0.6, "value": arr3[i] + 180 - 45, "dur": 0.2},
			{"delay": 0.8, "value": arr3[i] + 180 + 45, "dur": 0.2},
			{"delay": 1, "value": arr3[i] + 180 - 45, "dur": 0.2}
			])
		attack4.set_tweens([
			{"delay": 0, "value": arr4[i] + 180 - 45, "dur": 0.2}, 
			{"delay": 0.2, "value": arr4[i] + 180 + 45, "dur": 0.2},
			{"delay": 0.4, "value": arr4[i] + 180 - 45, "dur": 0.2},
			{"delay": 0.6, "value": arr4[i] + 180 + 45, "dur": 0.2},
			{"delay": 0.8, "value": arr4[i] + 180 - 45, "dur": 0.2},
			{"delay": 1, "value": arr4[i] + 180 + 45, "dur": 0.2}
			])
	
	await dash(575, 0.2)
	take_damage(50)
	
	await get_tree().create_timer(1).timeout
	attack1.play(self)
	attack2.play(self)
	attack5.play(self)
	await get_tree().create_timer(1).timeout
	attack3.play(self)
	attack4.play(self)
	attack6.play(self)
	await get_tree().create_timer(1).timeout
	attack1.play(self)
	attack2.play(self)
	attack5.play(self)
	await get_tree().create_timer(1).timeout
	attack3.play(self)
	attack4.play(self)
	attack6.play(self)
	
	await get_tree().create_timer(1).timeout


func boss_at4() -> void:
	var arr1: Array = []
	
	for i in range(0, 10):
		arr1.append(i * 36)
	
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 5, 4, [-36, -18, 0, 18, 36], 1, 600, [Vector2.ZERO], 1200, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 10, 1, arr1, 0.1, 400, [Vector2.ZERO], 1200, 1)
	
	attack1.set_aim("", 20)
	attack1.set_attack(1, attack2, true)
	attack1.set_tweens([], [{"delay": 0, "value": 0, "dur": 0.5}])
	attack1.set_tweens([], [{"delay": 0, "value": 0, "dur": 0.5}])
	attack1.set_tweens([], [{"delay": 0, "value": 0, "dur": 0.5}])
	attack1.set_tweens([], [{"delay": 0, "value": 0, "dur": 0.5}])
	attack1.set_tweens([], [{"delay": 0, "value": 0, "dur": 0.5}])
	
	attack2.set_aim("", 50)
	
	await dash(575, 0.2)
	
	attack1.play(self)
	
	await get_tree().create_timer(4).timeout


func boss_at5() -> void:
	var rand_mod: int = randi_range(0, 9)
	var arr1: Array = []
	var arr2: Array = []
	var arr3: Array = []
	var arr4: Array = []
	
	for i in range(0, 10):
		arr1.append(i * (360 / 10) + 9 + rand_mod)
		arr2.append(i * (360 / 10) + 27 + rand_mod)
		arr3.append(i * (360 / 10) + 18 + rand_mod)
		arr4.append(i * (360 / 10) + rand_mod)
	
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 10, 10, arr1, 0.1, 200, [Vector2.ZERO], 1200, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 10, 10, arr1, 0.1, 200, [Vector2.ZERO], 1200, 1)
	var attack3: Card.AttackPattren = Card.AttackPattren.new(bullet, 10, 10, arr1, 0.1, 200, [Vector2.ZERO], 1200, 1)
	var attack4: Card.AttackPattren = Card.AttackPattren.new(bullet, 10, 10, arr1, 0.1, 200, [Vector2.ZERO], 1200, 1)
	
	attack1.set_change_values([2, 2, 2, 2, 2, 2, 2, 2, 2, 2])
	attack2.set_change_values([-2, -2, -2, -2, -2, -2, -2, -2, -2, -2])
	attack3.set_change_values([2, 2, 2, 2, 2, 2, 2, 2, 2, 2])
	attack4.set_change_values([-2, -2, -2, -2, -2, -2, -2, -2, -2, -2])
	
	await get_tree().create_timer(1).timeout
	attack1.play(self)
	await get_tree().create_timer(1).timeout
	attack2.play(self)
	await get_tree().create_timer(1).timeout
	attack3.play(self)
	await get_tree().create_timer(1).timeout
	attack4.play(self)
	
	await get_tree().create_timer(1).timeout



func boss_at6() -> void:
	StatusEffects.apply_self_repair(self, 2, -10)
	await get_tree().create_timer(0.5).timeout


func update_status_bar() -> void:
	$StatusEffectsBar.update_status_effects(status_effects)


func _on_passive_timer_timeout() -> void:
	dash(get_tree().get_first_node_in_group("player").position.x, 0.2)
	await get_tree().create_timer(0.5).timeout
	passive_attack1.play(self)
	passive_attack2.play(self)
	passive_attack3.play(self)
