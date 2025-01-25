extends Enemy


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
@onready var laser: PackedScene = preload("res://Scenes/laser.tscn")
var awake: bool = false
var attacks: Array = [boss_at1, boss_at2, boss_at3, boss_at4, boss_at5]
var passive_attack1: Card.AttackPattren
var passive_attack2: Card.AttackPattren
var passive_attack3: Card.AttackPattren
var follow: bool = false
var last_stand: bool = false


func _ready() -> void:
	$Animations.play("default")
	passive_attack1 = Card.AttackPattren.new(laser, 1, 1, [0], 0.05, 800, [Vector2(0, -100)], 0, 1)
	passive_attack1.set_marker("line", 0.6)
	passive_attack1.set_laser_properties(0.2)
	passive_attack2 = Card.AttackPattren.new(laser, 1, 1, [0], 0.05, 800, [Vector2(0, -100)], 0, 1)
	passive_attack2.set_marker("line", 0.5)
	passive_attack2.set_laser_properties(0.2)
	passive_attack3 = Card.AttackPattren.new(laser, 1, 1, [0], 0.05, 800, [Vector2(0, -100)], 0, 1)
	passive_attack3.set_marker("line", 0.4)
	passive_attack3.set_laser_properties(0.2)
	hp = 1000
	scrap = 500
	$hp.text = str(hp)


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
	
	if hp <= 200 and not last_stand:
		last_stand = true
		await boss_at6()
	else:
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
	var attack: Card.AttackPattren = Card.AttackPattren.new(laser, 1, 1, [0], 0.05, 800, [Vector2(0, -100)], 0, 1)
	attack.set_laser_properties(0.2)
	attack.set_marker("line", 0.5)
	follow = true
	
	attack.play(self)
	await get_tree().create_timer(0.2).timeout
	attack.play(self)
	await get_tree().create_timer(0.2).timeout
	attack.play(self)
	await get_tree().create_timer(0.2).timeout
	attack.play(self)
	await get_tree().create_timer(0.2).timeout
	attack.play(self)
	await get_tree().create_timer(0.2).timeout
	attack.play(self)
	await get_tree().create_timer(0.2).timeout
	attack.play(self)
	await get_tree().create_timer(0.2).timeout
	attack.play(self)
	await get_tree().create_timer(0.2).timeout
	
	await get_tree().create_timer(1.5).timeout
	follow = false


func boss_at2() -> void:
	var attack1: Card.AttackPattren = Card.AttackPattren.new(laser, 2, 1, [-30, 30], 0.05, 800, [Vector2(0, 0)], 0, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(laser, 2, 1, [0], 0.3, 800, [Vector2(0, 0)], 0, 1)
	attack1.set_marker("line", 0.1)
	attack1.set_laser_properties(6.5)
	attack2.set_marker("line", 0.5)
	attack2.set_laser_properties(0.2)
	attack2.set_aim("", 50)
	
	await dash(575, 0.2)
	attack1.play(self)
	await get_tree().create_timer(0.5).timeout
	
	var j: int = 0
	while j < 20:
		attack2.play(self)
		j += 1
		await get_tree().create_timer(0.3).timeout
	
	await get_tree().create_timer(1).timeout


func boss_at3() -> void:
	var attack1: Card.AttackPattren = Card.AttackPattren.new(laser, 1, 1, [-55], 0.05, 800, [Vector2.ZERO], 1200, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(laser, 1, 1, [55], 0.05, 800, [Vector2.ZERO], 1200, 1)
	attack1.set_tweens([
		{"delay": 0.2, "value": 235, "dur": 1}
	])
	attack2.set_tweens([
		{"delay": 0.2, "value": 125, "dur": 1}
	])
	attack1.set_laser_properties(1.2)
	attack2.set_laser_properties(1.2)
	
	await dash(575, 0.2)
	if get_tree().get_first_node_in_group("player").position.x > 575:
		attack2.play(self)
		await get_tree().create_timer(1).timeout
		attack1.play(self)
	else:
		attack1.play(self)
		await get_tree().create_timer(0.8).timeout
		attack2.play(self)
	
	await get_tree().create_timer(1).timeout


func boss_at4() -> void:
	var j: int = 0
	
	while j < 6:
		var rand_start: int = randi_range(0, 30)
		var rand_arr: Array = []
		for i in range(12):
			rand_arr.append(rand_start + 30 * i)
			
		var attack1: Card.AttackPattren = Card.AttackPattren.new(laser, 12, 1, rand_arr, 0.1, 400, [Vector2.ZERO], 1200, 1)
		attack1.set_laser_properties(0.4)
		attack1.set_marker("line", 0.3)
		
		attack1.play(self)
		j += 1
		await get_tree().create_timer(1).timeout
	
	await get_tree().create_timer(1).timeout


func boss_at5() -> void:
	var attack1: Card.AttackPattren = Card.AttackPattren.new(laser, 2, 1, [0], 0.05, 800, [Vector2.ZERO], 1200, 1)
	var sub_attack: Card.AttackPattren = Card.AttackPattren.new(laser, 1, 1, [0], 0.05, 800, [Vector2.ZERO], 1200, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 5, [75, -75], 0.05, 400, [Vector2.ZERO], 1200, 1)
	attack1.set_laser_properties(6)
	attack1.set_abs_position([Vector2(400, -40), Vector2(750, -40)])
	attack1.set_marker("line", 0.2)
	sub_attack.set_marker("line", 0.4)
	sub_attack.set_laser_properties(0.2)
	attack2.set_change_values([5, -5])
	attack2.set_attack(1.1, sub_attack, false)
	attack2.set_look("player", 1, 0.5)
	
	attack2.set_tweens([], [
		{"delay": 1, "value": 0, "dur": 0.01}
	])
	attack2.set_tweens([], [
		{"delay": 1, "value": 0, "dur": 0.01}
	])
	
	await dash(575, 0.2)
	attack1.play(self)
	await get_tree().create_timer(0.5).timeout
	attack2.play(self)
	
	await get_tree().create_timer(4).timeout


func boss_at6() -> void:
	var attack1: Card.AttackPattren = Card.AttackPattren.new(laser, 8, 3, [0], 2, 800, [Vector2.ZERO], 1200, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 6, [30], 0.02, 400, [Vector2.ZERO], 1200, 1)
	attack1.set_laser_properties(1.6)
	attack1.set_abs_position([Vector2(225, -40), Vector2(325, -40), Vector2(425, -40), Vector2(525, -40), Vector2(625, -40), Vector2(725, -40), Vector2(825, -40), Vector2(925, -40)])
	attack1.set_change_values([], [], [Vector2(50, 0), Vector2(50, 0), Vector2(50, 0), Vector2(50, 0), Vector2(50, 0), Vector2(50, 0), Vector2(50, 0), Vector2(50, 0)])
	attack1.set_marker("line", 0.5)
	attack2.set_change_values([-10])
	
	attack2.set_tweens([
		{"delay": 0.3, "value": "player", "dur": 0.2}
	])
	
	await dash(575, 0.2)
	attack1.play(self)
	await get_tree().create_timer(0.6).timeout
	attack2.play(self)
	await get_tree().create_timer(1.6).timeout
	attack2.play(self)
	await get_tree().create_timer(1.6).timeout
	attack2.play(self)
	
	await get_tree().create_timer(6).timeout


func update_status_bar() -> void:
	$StatusEffectsBar.update_status_effects(status_effects)


func _on_passive_timer_timeout() -> void:
	await dash(randi_range(240, 915), 0.1)
	passive_attack1.play(self)
	await dash(randi_range(240, 915), 0.1)
	passive_attack2.play(self)
	await dash(randi_range(240, 915), 0.1)
	passive_attack3.play(self)
