extends Enemy


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
var awake: bool = false
var attacks: Array = [boss_at1, boss_at2, boss_at3]
var i: int = 0
var spining: bool = false


@onready var player: Node = get_tree().get_nodes_in_group("player")[0]
var aim_r: bool = false
var aim_l: bool = false
var aim_cr: bool = false
var aim_cl: bool = false


func _ready() -> void:
	hp = 1000
	scrap = 500
	$hp.text = str(hp)


func _process(_delta: float) -> void:
	if aim_r:
		$Sprites/R/gun_s.look_at(player.global_position)
		$Sprites/R/gun_s.rotation_degrees -= 90
	if aim_l:
		$Sprites/L/gun_s.look_at(player.global_position)
		$Sprites/L/gun_s.rotation_degrees -= 90
	if aim_cr:
		$Sprites/CR/gun_s.look_at(player.global_position)
		$Sprites/CR/gun_s.rotation_degrees -= 90
	if aim_cl:
		$Sprites/CL/gun_s.look_at(player.global_position)
		$Sprites/CL/gun_s.rotation_degrees -= 90


func start() -> void:
	#$Animations.play("boot_up")
	#await $Animations.animation_finished
	#$Animations.play("idle")
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
	var drone1: Card.AttackPattren = Card.AttackPattren.new(drone, 2, 3, [0], 1, 20, [Vector2.ZERO], 1200, 0)
	var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 20, [180], 0.05, 200, [Vector2.ZERO], 1200, 1)
	drone1.set_sprite_and_size(preload("res://Images/Enemies/security_system_drone.png"), 2, 0.2, Vector2(0.4, 0.4), Vector2(1, 1))
	drone1.set_drone_properties(2)
	drone1.set_attack(0, attack)
	var attack3: Card.AttackPattren = Card.AttackPattren.new(bullet, 5, 2, [150, 165, 180, 195, 210], 0.2, 400, [Vector2.ZERO], 1200, 1)
	var attack4: Card.AttackPattren = Card.AttackPattren.new(bullet, 5, 2, [150, 165, 180, 195, 210], 0.2, 400, [Vector2.ZERO], 1200, 1)
	drone1.set_abs_position([Vector2(225, 300), Vector2(925, 300)])
	drone1.set_change_values([],[],[Vector2(-20, 0),Vector2(20, 0)])
	drone1.set_tweens([],[],[{"delay": 0, "value": Vector2(800, 0), "dur": 1.2}])
	drone1.set_tweens([],[],[{"delay": 0, "value": Vector2(-800, 0), "dur": 1.2}])
	attack3.set_abs_position([Vector2(265, 200)])
	attack3.set_change_values([],[],[Vector2(100, 0),Vector2(100, 0),Vector2(100, 0),Vector2(100, 0),Vector2(100, 0)])
	attack4.set_abs_position([Vector2(785, 200)])
	attack4.set_change_values([],[],[Vector2(100, 0),Vector2(100, 0),Vector2(100, 0),Vector2(100, 0),Vector2(100, 0)])
	
	drone1.play(self)
	await get_tree().create_timer(1).timeout
	show_gun_l_l()
	show_gun_l_cl()
	show_gun_l_cr()
	show_gun_l_r()
	await get_tree().create_timer(3).timeout
	attack3.play(self)
	await get_tree().create_timer(0.4).timeout
	attack4.play(self)
	await get_tree().create_timer(1).timeout
	hide_gun_l_l()
	hide_gun_l_cl()
	hide_gun_l_cr()
	hide_gun_l_r()
	await get_tree().create_timer(1).timeout


func boss_at2() -> void:
	show_gun_s_cl()
	show_gun_s_cr()
	await get_tree().create_timer(1).timeout
	show_gun_s_l()
	show_gun_s_r()
	aim_r = true
	aim_l = true
	await get_tree().create_timer(2).timeout
	create_tween().tween_property($Sprites/CR/gun_s, "rotation_degrees", 1080, 5)
	create_tween().tween_property($Sprites/CL/gun_s, "rotation_degrees", -1080, 5)
	var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 5, [0], 0.01, 600, [Vector2.ZERO], 2000, 1)
	var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 5, [0], 0.01, 600, [Vector2.ZERO], 2000, 1)
	attack1.set_abs_position([$Sprites/R/gun_s.global_position])
	attack2.set_abs_position([$Sprites/L/gun_s.global_position])
	attack1.set_aim("player")
	attack2.set_aim("player")
	
	var j: int = 0
	while j < 40:
		var attack3: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [$Sprites/CR/gun_s.rotation_degrees + 180], 0.1, 300, [Vector2.ZERO], 2000, 1)
		var attack4: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [$Sprites/CL/gun_s.rotation_degrees + 180], 0.1, 300, [Vector2.ZERO], 2000, 1)
		attack3.set_abs_position([$Sprites/CR/gun_s.global_position])
		attack4.set_abs_position([$Sprites/CL/gun_s.global_position])
		attack3.set_properties(true)
		attack4.set_properties(true)
		attack3.play(self)
		attack4.play(self)
		
		if j % 5 == 0:
			if j == 0:
				Audio.play_sfx(Audio.sfx_alert)
				%line1.visible = true
				%line2.visible = true
				await get_tree().create_timer(0.2).timeout
				%line1.visible = false
				%line2.visible = false
			attack1.play(self)
			attack2.play(self)
		
		await get_tree().create_timer(0.1).timeout
		j += 1
	
	hide_gun_s_cl()
	hide_gun_s_cr()
	hide_gun_s_l()
	hide_gun_s_r()
	await get_tree().create_timer(1).timeout
	aim_r = false
	aim_l = false
	$Sprites/R/gun_s.rotation = 0
	$Sprites/L/gun_s.rotation = 0
	$Sprites/CR/gun_s.rotation = 0
	$Sprites/CL/gun_s.rotation = 0


func boss_at3() -> void:
	var drone1: Card.AttackPattren = Card.AttackPattren.new(drone, 4, 1, [0], 1, 0, [Vector2.ZERO], 1200, 0)
	var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 3, 5, [170, 180, 190], 1.5, 500, [Vector2.ZERO], 1200, 1)
	drone1.set_abs_position([Vector2(975,100),Vector2(175,150),Vector2(975,200),Vector2(175,250)])
	drone1.set_attack(0.5, attack)
	drone1.set_sprite_and_size(preload("res://Images/Enemies/security_system_drone.png"), 2, 0.2, Vector2(0.4, 0.4), Vector2(1, 1))
	drone1.set_look("player")
	drone1.set_drone_properties(10)
	drone1.set_tweens([],[],[
		{"delay": 0, "value": Vector2(-400, 0), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(0, 150), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(-150, 0), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(0, 150), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(-150, 0), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(-600, 0), "dur": 0.5},
	])
	drone1.set_tweens([],[],[
		{"delay": 0, "value": Vector2(400, 0), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(-150, 0), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(0, 150), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(-150, 0), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(0, 150), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(600, 0), "dur": 0.5},
	])
	drone1.set_tweens([],[],[
		{"delay": 0, "value": Vector2(-400, 0), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(0, 150), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(-150, 0), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(0, 150), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(-150, 0), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(-600, 0), "dur": 0.5},
	])
	drone1.set_tweens([],[],[
		{"delay": 0, "value": Vector2(400, 0), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(-150, 0), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(0, 150), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(-150, 0), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(randi_range(0, 150), randi_range(-50, 50)), "dur": 0.5},
		{"delay": 1, "value": Vector2(600, 0), "dur": 0.5},
	])
	
	drone1.play(self)
	
	await get_tree().create_timer(10).timeout


func show_gun_s_r() -> void:
	$AnimationsR.play("open")
	await $AnimationsR.animation_finished
	$AnimationsR.play("show_gun_s")


func show_gun_l_r() -> void:
	$AnimationsR.play("open")
	await $AnimationsR.animation_finished
	$AnimationsR.play("show_gun_l")


func show_gun_s_l() -> void:
	$AnimationsL.play("open")
	await $AnimationsL.animation_finished
	$AnimationsL.play("show_gun_s")

func show_gun_l_l() -> void:
	$AnimationsL.play("open")
	await $AnimationsL.animation_finished
	$AnimationsL.play("show_gun_l")


func show_gun_s_cr() -> void:
	$AnimationsCR.play("open")
	await $AnimationsCR.animation_finished
	$AnimationsCR.play("show_gun_s")


func show_gun_l_cr() -> void:
	$AnimationsCR.play("open")
	await $AnimationsCR.animation_finished
	$AnimationsCR.play("show_gun_l")


func show_gun_s_cl() -> void:
	$AnimationsCL.play("open")
	await $AnimationsCL.animation_finished
	$AnimationsCL.play("show_gun_s")


func show_gun_l_cl() -> void:
	$AnimationsCL.play("open")
	await $AnimationsCL.animation_finished
	$AnimationsCL.play("show_gun_l")


func hide_gun_s_r() -> void:
	$AnimationsR.play_backwards("show_gun_s")
	await $AnimationsR.animation_finished
	$AnimationsR.play_backwards("open")


func hide_gun_l_r() -> void:
	$AnimationsR.play_backwards("show_gun_l")
	await $AnimationsR.animation_finished
	$AnimationsR.play_backwards("open")


func hide_gun_s_l() -> void:
	$AnimationsL.play_backwards("show_gun_s")
	await $AnimationsL.animation_finished
	$AnimationsL.play_backwards("open")

func hide_gun_l_l() -> void:
	$AnimationsL.play_backwards("show_gun_l")
	await $AnimationsL.animation_finished
	$AnimationsL.play_backwards("open")


func hide_gun_s_cr() -> void:
	$AnimationsCR.play_backwards("show_gun_s")
	await $AnimationsCR.animation_finished
	$AnimationsCR.play_backwards("open")


func hide_gun_l_cr() -> void:
	$AnimationsCR.play_backwards("show_gun_l")
	await $AnimationsCR.animation_finished
	$AnimationsCR.play_backwards("open")


func hide_gun_s_cl() -> void:
	$AnimationsCL.play_backwards("show_gun_s")
	await $AnimationsCL.animation_finished
	$AnimationsCL.play_backwards("open")


func hide_gun_l_cl() -> void:
	$AnimationsCL.play_backwards("show_gun_l")
	await $AnimationsCL.animation_finished
	$AnimationsCL.play_backwards("open")


func update_status_bar() -> void:
	$StatusEffectsBar.update_status_effects(status_effects)

