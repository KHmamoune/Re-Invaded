extends Enemy


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
@onready var drone: PackedScene = preload("res://Scenes/drone.tscn")
@onready var player: Node = get_tree().get_first_node_in_group("player")
var awake: bool = false
var attacks: Array = [boss_at1, boss_at2, boss_at3, boss_at4, boss_at5, boss_at6]
var spining: bool = false
var passive_attack: Card.AttackPattren
var follow: bool = false
var bullet_speed_applied: bool = false
var self_repair_applied: bool = false


func _ready() -> void:
	$Animations.play("default")
	passive_attack = Card.AttackPattren.new(bullet, 1, 1, [0], 0.05, 1500, [Vector2(0, 0)], 800, 1)
	passive_attack.set_marker("line", 0.2)
	hp = 1000
	scrap = 500
	$hp.text = str(hp)


func _process(_delta: float) -> void:
	if follow:
		if player.position.x - 5 > position.x:
			position.x += 5
		elif player.position.x + 5 < position.x:
			position.x -= 5


func start() -> void:
	awake = true
	$Animations.play("default")
	$ShootTimer.start()


func _on_shoot_timer_timeout() -> void:
	follow = false
	$PassiveTimer.stop()
	$ShootTimer.stop()
	await get_tree().create_timer(0.1).timeout
	
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
	var attack1: Card.AttackPattren = Card.AttackPattren.new(drone, 2, 1, [0], 0.05, 0, [Vector2.ZERO], 1200, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 8, 10, [0, 45, 90, 135, 180, 225, 270, 315], 0.1, 500, [Vector2.ZERO], 2000, 1)
	
	attack1.set_tweens([], [], [
		{"delay": 0, "value": Vector2(100, 100), "dur": 1}
	])
	attack1.set_tweens([], [], [
		{"delay": 0, "value": Vector2(-100, 100), "dur": 1}
	])
	
	if position.x > 575:
		attack2.set_change_values([5,5,5,5,5,5,5,5])
	else:
		attack2.set_change_values([-5,-5,-5,-5,-5,-5,-5,-5])
	
	attack1.set_attack(1.2, attack2)
	attack1.set_drone_properties(2.2)
	
	attack1.play(self)
	await get_tree().create_timer(2).timeout


func boss_at2() -> void:
	var drone1: Card.AttackPattren = Card.AttackPattren.new(drone, 1, 1, [0], 0.05, 0, [Vector2.ZERO], 1200, 1)
	var drone2: Card.AttackPattren = Card.AttackPattren.new(drone, 1, 1, [0], 0.05, 0, [Vector2.ZERO], 1200, 1)
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 4, 10, [-75, -65, -55, -45], 0.1, 500, [Vector2.ZERO], 2000, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 4, 10, [75, 65, 55, 45], 0.1, 500, [Vector2.ZERO], 2000, 1)
	
	drone1.set_tweens([], [], [
		{"delay": 0, "value": Vector2(200, 100), "dur": 1}
	])
	drone2.set_tweens([], [], [
		{"delay": 0, "value": Vector2(-200, 100), "dur": 1}
	])
	
	attack1.set_properties(true)
	attack2.set_properties(true)
	drone1.set_attack(1.2, attack1)
	drone1.set_drone_properties(2)
	drone2.set_attack(1.2, attack2)
	drone2.set_drone_properties(2)
	
	await dash(575, 0.2)
	drone1.play(self)
	drone2.play(self)
	await get_tree().create_timer(2).timeout


func boss_at3() -> void:
	var drone1: Card.AttackPattren = Card.AttackPattren.new(drone, 2, 1, [0], 0.05, 0, [Vector2.ZERO], 1200, 1)
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 40, [0], 0.1, 1000, [Vector2.ZERO], 2000, 1)
	
	drone1.set_tweens([], [], [
		{"delay": 0, "value": Vector2(80, 0), "dur": 1}
	])
	drone1.set_tweens([], [], [
		{"delay": 0, "value": Vector2(-80, 0), "dur": 1}
	])
	
	attack1.set_properties(true)
	drone1.set_properties(false, true)
	drone1.set_attack(1.2, attack1)
	drone1.set_drone_properties(10)
	
	drone1.play(self)
	await get_tree().create_timer(2.5).timeout


func boss_at4() -> void:
	var drone1: Card.AttackPattren = Card.AttackPattren.new(drone, 1, 1, [0], 0.05, 1000, [Vector2.ZERO], 1200, 1)
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [0], 0.2, 900, [Vector2.ZERO], 1200, 1)
	drone1.set_sprite_and_size(preload("res://Images/Characters/charger.png"), 2, 0.5, Vector2(0.4,0.4), Vector2(1.5,2))
	drone1.set_drone_properties(5)
	drone1.set_after_image(0, 0.02)
	attack1.set_marker("line", 0.2)
	
	var i: int = 1
	
	while i < 21:
		if i % 5 == 0:
			await dash(player.position.x, 0.2)
			attack1.play(self)
		
		drone1.set_abs_position([Vector2(randi_range(230, 920), -10)])
		drone1.play(self)
		await get_tree().create_timer(0.3).timeout
		i += 1
	
	await get_tree().create_timer(1).timeout


func boss_at5() -> void:
	var drone1: Card.AttackPattren = Card.AttackPattren.new(drone, 1, 10, [-50], 0.05, 500, [Vector2.ZERO], 1200, 1)
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 10, 1, [0, 36, 72, 108, 144, 180, 216, 252, 288, 324], 0.1, 500, [Vector2.ZERO], 2000, 1)
	drone1.set_change_values([10])
	attack1.set_aim("", 20)
	
	drone1.set_tweens([], [
		{"delay": 0, "value": 0, "dur": 0.4}
	])
	
	drone1.set_attack(0.7, attack1, true)
	drone1.set_drone_properties(4)
	
	drone1.play(self)
	await get_tree().create_timer(2.5).timeout


func boss_at6() -> void:
	var drone1: Card.AttackPattren = Card.AttackPattren.new(drone, 1, 1, [45], 0.05, 500, [Vector2.ZERO], 1200, 1)
	var drone2: Card.AttackPattren = Card.AttackPattren.new(drone, 1, 1, [-45], 0.05, 500, [Vector2.ZERO], 1200, 1)
	var drone3: Card.AttackPattren = Card.AttackPattren.new(drone, 2, 1, [90, -90], 0.05, 0, [Vector2.ZERO], 1200, 1)
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 50, [0], 0.05, 300, [Vector2.ZERO], 2000, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 50, [0], 0.05, 300, [Vector2.ZERO], 2000, 1)
	var attack3: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 5, [180], 0.05, 500, [Vector2.ZERO], 2000, 1)
	attack1.set_change_values([19])
	attack2.set_change_values([-19])
	attack3.set_marker("line", 0.1)
	
	attack1.set_tweens([{
		"delay": 0, "value": 90, "dur": 0.8
	}], [], [], [], true)
	attack2.set_tweens([{
		"delay": 0, "value": -90, "dur": 0.8
	}], [], [], [], true)
	
	drone1.set_tweens([], [
		{"delay": 0, "value": 0, "dur": 1}
	])
	drone2.set_tweens([], [
		{"delay": 0, "value": 0, "dur": 1}
	])
	
	drone3.set_tweens([], [
		{"delay": 0, "value": 0, "dur": 1}
	], [
		{"delay": 0, "value": Vector2(100, 0), "dur": 0.5}
	])
	drone3.set_tweens([], [
		{"delay": 0, "value": 0, "dur": 1}
	], [
		{"delay": 0, "value": Vector2(-100, 0), "dur": 0.5}
	])
	
	drone1.set_attack(1, attack1)
	drone1.set_drone_properties(4)
	drone2.set_attack(1, attack2)
	drone2.set_drone_properties(4)
	drone3.set_look("player")
	drone3.set_attack(0.8, attack3)
	drone3.set_drone_properties(2)
	
	await dash(575, 0.2)
	drone1.play(self)
	drone2.play(self)
	await get_tree().create_timer(0.5).timeout
	drone3.play(self)
	await get_tree().create_timer(1.5).timeout
	drone3.play(self)
	await get_tree().create_timer(3).timeout


func update_status_bar() -> void:
	$StatusEffectsBar.update_status_effects(status_effects)


func _on_passive_timer_timeout() -> void:
	await dash(player.position.x, 0.2)
	passive_attack.play(self)
