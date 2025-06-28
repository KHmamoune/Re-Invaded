extends Enemy


var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
var shield: PackedScene = preload("res://Scenes/shield.tscn")
var awake: bool = false
var attacks: Array = [boss_at1, boss_at2, boss_at3]
var i: int = 0

var boss_at1_attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 25, [180], 0.15, 400, [Vector2.ZERO], 700, 1)
var boss_at1_attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 25, [180], 0.15, 400, [Vector2.ZERO], 700, 1)
var boss_at2_attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 10, 1, [180], 0.15, 400, [Vector2.ZERO], 700, 1)
var boss_at3_shield1: Card.AttackPattren = Card.AttackPattren.new(shield, 1, 1, [180], 0.15, 0, [Vector2(0, 30)], 700, 1)
var boss_at3_attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 6, 10, [0, 60, 120, 180, 240, 300], 0.2, 400, [Vector2(0, 30)], 700, 1)
var boss_at3_attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 6, 10, [0, 60, 120, 180, 240, 300], 0.2, 400, [Vector2(0, 30)], 700, 1)


func _ready() -> void:
	color = Color.CYAN
	set_up_hp(200, Vector2(0, 70))
	set_up_status_effects(Vector2(-15, 85))
	scrap = 200
	
	boss_at1_attack1.set_sprite_preset(gv.icicle_bullet_preset, Color.WHITE)
	boss_at1_attack2.set_sprite_preset(gv.icicle_bullet_preset, Color.WHITE)
	boss_at1_attack1.set_aim("", 80)
	boss_at1_attack2.set_aim("", 80)
	
	boss_at2_attack1.set_sprite_preset(gv.icicle_bullet_preset, Color.WHITE)
	boss_at2_attack1.set_tweens([], [
		{"delay": 0, "value": 600, "dur": 2}
	])
	boss_at2_attack1.set_bullet_effect(preload("res://Scenes/bullet_squar_particles.tscn"), Color.CYAN)
	
	boss_at3_shield1.set_shield_properties(4, Vector2(4, 4), true)
	boss_at3_shield1.set_sprite_preset(gv.crystal_shield_preset, Color.WHITE)
	boss_at3_attack1.set_change_values([10,10,10,10,10,10])
	boss_at3_attack2.set_change_values([-10,-10,-10,-10,-10,-10])
	boss_at3_attack1.set_sprite_preset(gv.icicle_bullet_preset, Color.WHITE)
	boss_at3_attack2.set_sprite_preset(gv.icicle_bullet_preset, Color.WHITE)


func start() -> void:
	$Animations.play("wake_up")
	await $Animations.animation_finished
	$Animations.play("idle")
	awake = true
	$ShootTimer.start()


func _on_shoot_timer_timeout() -> void:
	$ShootTimer.stop()
	$Animations.stop()
	
	var og_pos_r: Vector2 = $Rhand.global_position
	var og_rot_r: float = $Rhand.rotation_degrees
	var og_pos_l: Vector2 = $Lhand.global_position
	var og_rot_l: float = $Lhand.rotation_degrees
	
	await attacks[randi_range(0, len(attacks)-1)].call()
	
	await return_og(og_pos_r, og_pos_l, og_rot_r, og_rot_l)
	
	$ShootTimer.start()
	$Animations.play("idle")


func return_og(opr: Vector2, opl: Vector2, orr: float, orl: float) -> void:
	var t: Tween = create_tween()
	t.parallel().tween_property($Rhand, "global_position", opr, 0.3)
	t.parallel().tween_property($Rhand, "rotation_degrees", orr, 0.3)
	t.parallel().tween_property($Lhand, "global_position", opl, 0.3)
	t.parallel().tween_property($Lhand, "rotation_degrees", orl, 0.3)
	await t.finished


func boss_at1() -> void:
	create_tween().tween_property($Rhand, "global_position", $Rhand.global_position + Vector2(0, 50), 0.2)
	create_tween().tween_property($Rhand, "rotation_degrees", 0, 0.2)
	create_tween().tween_property($Lhand, "global_position", $Lhand.global_position + Vector2(0, 50), 0.2)
	create_tween().tween_property($Lhand, "rotation_degrees", 0, 0.2)
	await  get_tree().create_timer(0.4).timeout
	$Animations.play("open_hands")
	
	var pos1: Vector2 = $Rhand.global_position
	var pos2: Vector2 = $Lhand.global_position
	boss_at1_attack1.set_abs_position([pos1, pos1, pos1])
	boss_at1_attack2.set_abs_position([pos2, pos2, pos2])
	
	if not is_dead:
		boss_at1_attack1.play(self)
		boss_at1_attack2.play(self)
	await  get_tree().create_timer(2.5).timeout
	$Animations.play_backwards("open_hands")
	await  get_tree().create_timer(1).timeout


func boss_at2() -> void:
	var t: Tween = create_tween()
	$AfterImageTimer.start()
	t.tween_property(self, "position:x", position.x + 300, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(self, "position:x", position.x - 300, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_delay(0.8)
	t.tween_property(self, "position:x", position.x + 300, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_delay(0.8)
	t.tween_property(self, "position:x", position.x - 300, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_delay(0.8)
	t.tween_property(self, "position:x", position.x, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_delay(0.8)
	
	
	for i: int in range(0, 4):
		Audio.play_sfx(Audio.sfx_heavy_move)
		await get_tree().create_timer(0.4).timeout
		Audio.play_sfx(Audio.sfx_wall_crash)
		boss_at2_attack1.set_abs_position([
			Vector2(randi_range(0,70)+225,-20),
			Vector2(randi_range(70,140)+225,-20),
			Vector2(randi_range(140,210)+225,-20),
			Vector2(randi_range(210,280)+225,-20),
			Vector2(randi_range(280,350)+225,-20),
			Vector2(randi_range(350,420)+225,-20),
			Vector2(randi_range(420,490)+225,-20),
			Vector2(randi_range(490,560)+225,-20),
			Vector2(randi_range(560,630)+225,-20),
			Vector2(randi_range(630,700)+225,-20)
			])
		boss_at2_attack1.play(self)
		await get_tree().create_timer(0.2).timeout
		boss_at2_attack1.set_abs_position([
			Vector2(randi_range(0,70)+225,-20),
			Vector2(randi_range(70,140)+225,-20),
			Vector2(randi_range(140,210)+225,-20),
			Vector2(randi_range(210,280)+225,-20),
			Vector2(randi_range(280,350)+225,-20),
			Vector2(randi_range(350,420)+225,-20),
			Vector2(randi_range(420,490)+225,-20),
			Vector2(randi_range(490,560)+225,-20),
			Vector2(randi_range(560,630)+225,-20),
			Vector2(randi_range(630,700)+225,-20)
			])
		boss_at2_attack1.play(self)
		await get_tree().create_timer(0.6).timeout
	
	await get_tree().create_timer(2).timeout
	$AfterImageTimer.stop()


func boss_at3() -> void:
	boss_at3_shield1.play(self)
	await get_tree().create_timer(0.5).timeout
	boss_at3_attack1.play(self)
	boss_at3_attack2.play(self)
	await get_tree().create_timer(3).timeout
