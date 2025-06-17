extends Enemy


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
@onready var explosion: PackedScene = preload("res://Scenes/explosion.tscn")
@onready var drone: PackedScene = preload("res://Scenes/drone.tscn")
@onready var laser: PackedScene = preload("res://Scenes/laser.tscn")
var awake: bool = false
var attacks: Array = [boss_at1,boss_at2,boss_at3,boss_at4,boss_at5,boss_at6]
var i: int = 0
var started: bool = false
var used_at7: bool = false

@onready var player: Node = get_tree().get_nodes_in_group("player")[0]


func _ready() -> void:
	set_up_hp(500, Vector2(0, 50))
	hp_node.visible = false
	set_up_status_effects(Vector2(-15, 65))
	scrap = 1000


func start() -> void:
	if started:
		return
	
	$Animations.play("boot_up")
	await $Animations.animation_finished
	$Animations.play("idle")
	hp_node.visible = true
	awake = true
	$ShootTimer.start()
	started = true


func _on_shoot_timer_timeout() -> void:
	$ShootTimer.stop()
	
	if hp <= 200 and !used_at7:
		used_at7 = true
		await boss_at7()
	else:
		await attacks[randi_range(0, len(attacks)-1)].call()
	
	$ShootTimer.start()


func boss_at1() -> void:
	$Body/Star.modulate = Color.CYAN
	$Animations.play("change_color")
	await $Animations.animation_finished
	$Animations.play("idle")
	
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 3, [180], 0.1, 400, [Vector2.ZERO], 1200, 1)
	attack1.set_change_values([], [300, 300], [Vector2(-50, 0), Vector2(50, 0)])
	attack1.set_sprite_preset(gv.bullet1_preset, Color.BLUE)
	
	for j in range(0, 10):
		attack1.set_abs_position([Vector2(randi_range(300, 800), -50)])
		attack1.play(self)
		await get_tree().create_timer(0.5).timeout


func boss_at2() -> void:
	$Body/Star.modulate = Color.ORANGE
	$Animations.play("change_color")
	await $Animations.animation_finished
	$Animations.play("idle")
	
	var attack1: Card.AttackPattren = Card.AttackPattren.new(explosion, 1, 1, [0], 0.1, 0, [Vector2.ZERO], 1200, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(explosion, 8, 1, [0], 0.1, 0, [Vector2(100, 0),Vector2(-100, 0),Vector2(0, 100),Vector2(0, -100),Vector2(80, 80),Vector2(80, -80),Vector2(-80, 80),Vector2(-80, -80),], 1200, 1)
	attack1.set_marker("marker", 1.5)
	attack2.set_marker("marker", 1.7)
	
	for j in range(0, 3):
		attack1.set_abs_position([get_tree().get_first_node_in_group("player").position])
		attack2.set_abs_position([get_tree().get_first_node_in_group("player").position])
		attack1.play(self)
		await get_tree().create_timer(0.2).timeout
		attack2.play(self)
		await get_tree().create_timer(1.2).timeout
	
	await get_tree().create_timer(2).timeout


func boss_at3() -> void:
	$Body/Star.modulate = Color.RED
	$Animations.play("change_color")
	await $Animations.animation_finished
	$Animations.play("idle")
	
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 10, [90, -90], 0.1, 300, [Vector2.ZERO], 1200, 1)
	attack1.set_change_values([10, -10])
	attack1.set_sprite_preset(gv.bullet2_preset, Color.RED)
	attack1.set_properties(true)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 10, [85, -85], 0.1, 200, [Vector2.ZERO], 1200, 1)
	attack2.set_change_values([10, -10])
	attack2.set_sprite_preset(gv.bullet2_preset, Color.RED)
	attack2.set_properties(true)
	
	attack1.play(self)
	await get_tree().create_timer(0.3).timeout
	attack2.play(self)
	await get_tree().create_timer(1).timeout
	attack1.play(self)
	await get_tree().create_timer(0.3).timeout
	attack2.play(self)
	await get_tree().create_timer(2).timeout


func boss_at4() -> void:
	$Body/Star.modulate = Color.WEB_GREEN
	$Animations.play("change_color")
	await $Animations.animation_finished
	$Animations.play("idle")
	
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 10, [0], 0.1, 700, [Vector2.ZERO], 1200, 1)
	attack1.set_change_values([], [], [Vector2(50, 0),Vector2(-50, 0)])
	attack1.set_sprite_preset(gv.wire_bullet_preset, Color.WHITE)
	attack1.set_aim("player")
	
	for j in range(0, 4):
		if j % 2 == 0:
			attack1.set_abs_position([Vector2(0, -500)])
		else:
			attack1.set_abs_position([Vector2(900, -500)])
		
		attack1.play(self)
		await get_tree().create_timer(2).timeout


func boss_at5() -> void:
	$Body/Star.modulate = Color.YELLOW
	$Animations.play("change_color")
	await $Animations.animation_finished
	$Animations.play("idle")
	
	var attack1: Card.AttackPattren = Card.AttackPattren.new(laser, 2, 2, [180], 2, 0, [Vector2.ZERO], 1200, 1)
	attack1.set_laser_properties(3)
	attack1.set_abs_position([Vector2(225, 0), Vector2(925, 0)])
	attack1.set_sfx(Audio.sfx_laser)
	attack1.set_tweens([], [], [
		{"delay": 0.4, "value": Vector2(700, 0), "dur": 4},
	])
	attack1.set_tweens([], [], [
		{"delay": 0.4, "value": Vector2(-700, 0), "dur": 4},
	])
	
	attack1.play(self)
	await get_tree().create_timer(2).timeout


func boss_at6() -> void:
	$Body/Star.modulate = Color.BLUE_VIOLET
	$Animations.play("change_color")
	await $Animations.animation_finished
	$Animations.play("idle")
	
	var drone1: Card.AttackPattren = Card.AttackPattren.new(drone, 4, 1, [0], 1, 0, [Vector2.ZERO], 1200, 0)
	var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 5, 5, [160, 170, 180, 190, 200], 1.5, 500, [Vector2.ZERO], 1200, 1)
	attack.set_sprite_preset(gv.bullet2_preset, Color.DARK_VIOLET)
	drone1.set_abs_position([Vector2(975,100),Vector2(175,150),Vector2(975,200),Vector2(175,250)])
	drone1.set_attack(0.5, attack)
	drone1.set_sprite_and_size(preload("res://Assets/Enemies/security_system_drone.png"), 2, 0.2, Vector2(1, 1), Vector2(1, 1))
	drone1.set_look("player")
	drone1.set_drone_properties(7)
	drone1.set_tweens([],[],[
		{"delay": 0, "value": Vector2(-400, 0), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(0, 150), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(-150, 0), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(0, 150), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(-150, 0), randi_range(-50, 50)), "dur": 0.5},
	])
	drone1.set_tweens([],[],[
		{"delay": 0, "value": Vector2(400, 0), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(-150, 0), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(0, 150), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(-150, 0), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(0, 150), randi_range(-50, 50)), "dur": 0.5},
	])
	drone1.set_tweens([],[],[
		{"delay": 0, "value": Vector2(-400, 0), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(0, 150), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(-150, 0), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(0, 150), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(-150, 0), randi_range(-50, 50)), "dur": 0.5},
	])
	drone1.set_tweens([],[],[
		{"delay": 0, "value": Vector2(400, 0), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(-150, 0), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(0, 150), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(-150, 0), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(0, 150), randi_range(-50, 50)), "dur": 0.5},
	])
	drone1.set_after_image(0.1, 0.02)
	
	drone1.play(self)
	
	await get_tree().create_timer(10).timeout


func boss_at7() -> void:
	$Body/Star.modulate = Color.DIM_GRAY
	$Animations.play("change_color")
	await $Animations.animation_finished
	$Animations.play("idle")
	
	$SecuritySystemPillar.at1()
	$SecuritySystemPillar2.at2()
	
	await get_tree().create_timer(20).timeout


func hit_flash() -> void:
	$Body.material.set_shader_parameter("flash_modifier", 0.5)
	await get_tree().create_timer(0.02).timeout
	$Body.material.set_shader_parameter("flash_modifier", 0)


func change_gem_color() -> void:
	$Body/SecuritySystemGem.modulate = $Body/Star.modulate
