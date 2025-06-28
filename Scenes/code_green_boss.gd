extends Enemy


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
@onready var shield: PackedScene = preload("res://Scenes/shield.tscn")
@onready var drone: PackedScene = preload("res://Scenes/drone.tscn")

var awake: bool = false
var attacks: Array = [boss_at1, boss_at2, boss_at3, boss_at4, boss_at5]
var passive_attack: Card.AttackPattren
var follow: bool = false
var killed: bool = false
var nullified: bool = false
var attacking: bool = false


func _ready() -> void:
	$Animations.play("default")
	passive_attack = Card.AttackPattren.new(bullet, 2, 10, [0], 0.05, 400, [Vector2(0, 0)], 800, 1)
	passive_attack.set_aim("player")
	passive_attack.set_tweens([
		{"delay": 0, "value": 25, "dur": 0.1},
		{"delay": 0.1, "value": -50, "dur": 0.2},
		{"delay": 0.2, "value": 50, "dur": 0.2},
		{"delay": 0.2, "value": -50, "dur": 0.2},
		{"delay": 0.2, "value": 50, "dur": 0.2},
		{"delay": 0.2, "value": -50, "dur": 0.2},
		{"delay": 0.2, "value": 50, "dur": 0.2},
		{"delay": 0.2, "value": -50, "dur": 0.2},
		{"delay": 0.2, "value": 50, "dur": 0.2},
		{"delay": 0.2, "value": -50, "dur": 0.2},
	], [], [], [], true)
	passive_attack.set_tweens([
		{"delay": 0, "value": -25, "dur": 0.1},
		{"delay": 0.1, "value": 50, "dur": 0.2},
		{"delay": 0.2, "value": -50, "dur": 0.2},
		{"delay": 0.2, "value": 50, "dur": 0.2},
		{"delay": 0.2, "value": -50, "dur": 0.2},
		{"delay": 0.2, "value": 50, "dur": 0.2},
		{"delay": 0.2, "value": -50, "dur": 0.2},
		{"delay": 0.2, "value": 50, "dur": 0.2},
		{"delay": 0.2, "value": -50, "dur": 0.2},
		{"delay": 0.2, "value": 50, "dur": 0.2},
	], [], [], [], true)
	set_up_hp(1000, Vector2(0, 50))
	set_up_status_effects(Vector2(-15, 65))
	scrap = 500


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
	await get_tree().create_timer(0.3).timeout
	
	attacking = true
	await attacks[randi_range(0, len(attacks)-1)].call()
	attacking = false
	
	if !killed or nullified:
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
	after_image_instance.z_index = -1
	get_parent().add_child(after_image_instance)


func boss_at0() -> void:
	$PassiveTimer.start()


func boss_at1() -> void:
	var shield1: Card.AttackPattren = Card.AttackPattren.new(shield, 1, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 1)
	var drone1: Card.AttackPattren = Card.AttackPattren.new(drone, 2, 1, [0], 1, 0, [Vector2.ZERO], 1200, 0)
	var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 30, [180], 0.1, 350, [Vector2.ZERO], 1200, 1)
	attack.set_aim("", 40)
	await dash(575, 0.2)
	
	drone1.set_abs_position([global_position, global_position])
	drone1.set_attack(0.5, attack)
	drone1.set_look("player")
	drone1.set_drone_properties(6)
	drone1.set_tweens([],[],[
		{"delay": 0.5, "value": Vector2(150, 50), "dur": 0.5},
		{"delay": 4, "value": Vector2(-150, -50), "dur": 0.5},
	])
	drone1.set_tweens([],[],[
		{"delay": 0.5, "value": Vector2(-150, 50), "dur": 0.5},
		{"delay": 4, "value": Vector2(150, -50), "dur": 0.5},
	])
	
	shield1.set_shield_properties(3, Vector2(1.5, 1.5))
	shield1.set_properties(false, true)
	shield1.play(self)
	drone1.play(self)
	
	await get_tree().create_timer(5).timeout


func boss_at2() -> void:
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 8, [160, 200], 0.1, 400, [Vector2.ZERO], 1800, 1)
	attack1.set_change_values([-8, 8])
	attack1.set_tweens([], [
		{"delay": 0.5, "value": 500, "dur": 0.5}
	])
	attack1.set_tweens([], [
		{"delay": 0.5, "value": 500, "dur": 0.5}
	])
	attack1.set_look("player", 0.5, 1)
	
	await dash(575, 0.2)
	attack1.play(self)
	await get_tree().create_timer(1).timeout
	await dash(475, 0.2)
	attack1.play(self)
	await get_tree().create_timer(1).timeout
	await dash(675, 0.2)
	attack1.play(self)
	
	await get_tree().create_timer(3).timeout


func boss_at3() -> void:
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 40, [0], 0.1, 300, [Vector2.ZERO], 1200, 1)
	var shield1: Card.AttackPattren = Card.AttackPattren.new(shield, 1, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 1)
	shield1.set_shield_properties(3, Vector2(0.5, 0.5))
	shield1.set_properties(false, true)
	attack1.set_aim("", 60)
	attack1.set_attack(0, shield1)
	
	await dash(575, 0.2)
	attack1.play(self)
	
	await get_tree().create_timer(4).timeout


func boss_at4() -> void:
	var shield1: Card.AttackPattren = Card.AttackPattren.new(shield, 1, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 1)
	shield1.set_shield_properties(5, Vector2(1.5, 1.5), true)
	shield1.set_properties(false, true)
	shield1.play(self)
	
	await get_tree().create_timer(1).timeout


func boss_at5() -> void:
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 50, [-20, 20], 0.1, 400, [Vector2.ZERO], 1200, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 20, [90, -90], 0.05, 300, [Vector2.ZERO], 1200, 1)
	var attack3: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [0], 0.1, 500, [Vector2.ZERO], 1200, 1)
	attack3.set_aim("player")
	attack3.set_sfx(null)
	attack2.set_change_values([2, -2])
	attack2.set_attack(1.5, attack3)
	
	await dash(575, 0.2)
	attack1.play(self)
	await get_tree().create_timer(0.4).timeout
	attack2.play(self)
	await get_tree().create_timer(1.5).timeout
	attack2.play(self)
	await get_tree().create_timer(1.5).timeout
	attack2.play(self)
	
	await get_tree().create_timer(4).timeout


func boss_at6() -> void:
	while attacking:
		await get_tree().create_timer(0.1).timeout
	
	var shield1: Card.AttackPattren = Card.AttackPattren.new(shield, 1, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 1)
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 20, [-45], 0.1, 400, [Vector2.ZERO], 1200, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 20, [45], 0.1, 400, [Vector2.ZERO], 1200, 1)
	var attack3: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 2, [45], 0.5, 350, [Vector2.ZERO], 1200, 1)
	attack1.set_change_values([5])
	attack2.set_change_values([-5])
	attack3.set_change_values([-90])
	
	attack1.set_tweens([
		{"delay": 0.5, "value": -20, "dur": 1}
	], [], [], [], true)
	
	attack2.set_tweens([
		{"delay": 0.5, "value": 20, "dur": 1}
	], [], [], [], true)
	
	attack3.set_tweens([], [
		{"delay": 0, "value": 0, "dur": 0.5},
		{"delay": 0.5, "value": 600, "dur": 0.2},
	])
	
	attack3.set_look("player", 0.5, 0.5)
	
	await dash(575, 0.2)
	
	shield1.set_shield_properties(10, Vector2(1.5, 1.5))
	shield1.set_properties(false, true)
	shield1.play(self)
	$Hurtbox.set_deferred("disabled", false)
	
	attack1.play(self)
	attack3.play(self)
	await get_tree().create_timer(1).timeout
	attack2.play(self)
	await get_tree().create_timer(1).timeout
	attack1.play(self)
	attack3.play(self)
	await get_tree().create_timer(1).timeout
	attack2.play(self)
	await get_tree().create_timer(1).timeout
	attack1.play(self)
	attack3.play(self)
	await get_tree().create_timer(1).timeout
	attack2.play(self)
	await get_tree().create_timer(1).timeout
	
	await get_tree().create_timer(4).timeout
	nullified = true
	$ShootTimer.start()


func _on_passive_timer_timeout() -> void:
	await dash(randf_range(250, 900), 0.2)
	passive_attack.play(self)


func take_damage(dmg: int, area: Node = null) -> void:
	Audio.play_sfx(Audio.sfx_hit)
	hit_flash()
	hp -= dmg
	hp_node.get_child(0).text = str(hp)
	
	if hp <= 0 and !is_dead:
		if !killed:
			killed = true
			$Hurtbox.set_deferred("disabled", true)
			$hp.text = "1"
			$ShootTimer.stop()
			boss_at6()
			return
		
		is_dead = true
		play_death_effect()
		$Hurtbox.set_deferred("disabled", true)
		
		for effect: Card.CardStats in area.on_kill_effects:
			var player: Node = get_tree().get_first_node_in_group("player")
			effect.play(player, self)
		
		dead.emit(scrap)
		queue_free()
