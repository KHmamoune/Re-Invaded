extends Area2D


signal dead


var hp: int = 200
var is_dead: bool= false
var awake: bool = false
var attacks: Array = [boss_at1, boss_at2, boss_at3]
var i: int = 0
var scrap: int = 200
var status_effects: Dictionary = {}


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")


func _ready() -> void:
	$hp.text = str(hp)
	

func start() -> void:
	$Animations.play("boot_up")
	await $Animations.animation_finished
	$Animations.play("idle")
	awake = true
	$ShootTimer.start()
	$MoveTimer.start()


func take_damage(dmg: int) -> void:
	Audio.play_sfx(Audio.sfx_hit)
	hp -= dmg
	$hp.text = str(hp)
	
	if hp <= 0 and !is_dead:
		is_dead = true
		$Hurtbox.set_deferred("disabled", true)
		emit_signal("dead")
		queue_free()


func _on_shoot_timer_timeout() -> void:
	$ShootTimer.stop()
	$Animations.stop()
	$MoveTimer.stop()
	
	var og_pos_r: Vector2 = $Rhand.global_position
	var og_rot_r: float = $Rhand.rotation_degrees
	var og_pos_l: Vector2 = $Lhand.global_position
	var og_rot_l: float = $Lhand.rotation_degrees
	
	await attacks[i].call()
	
	i += 1
	if i >= len(attacks):
		i = 0
	
	await return_og(og_pos_r, og_pos_l, og_rot_r, og_rot_l)
	
	$MoveTimer.start()
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
	for j in range(3):
		create_tween().tween_property($Rhand, "global_position", get_tree().get_first_node_in_group("player").position - Vector2(0, 300), 0.2)
		create_tween().tween_property($Rhand, "rotation_degrees", 70, 0.2)
		await  get_tree().create_timer(0.4).timeout
		
		var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 3, 6, [200, 180, 160], 0.05, 1000, [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO], 700, 1)
		attack.set_marker("line", 0.2)
		var pos: Vector2 = $Rhand.global_position
		attack.set_abs_position([pos, pos, pos])
		
		if not is_dead:
			attack.play(self)
		await  get_tree().create_timer(0.3).timeout


func boss_at2() -> void:
	create_tween().tween_property($Rhand, "global_position", Vector2(260, 400), 0.2)
	create_tween().tween_property($Rhand, "rotation_degrees", 70, 0.2)
	create_tween().tween_property($Lhand, "global_position", Vector2(890, 400), 0.2)
	create_tween().tween_property($Lhand, "rotation_degrees", -70, 0.2)
	await  get_tree().create_timer(0.4).timeout
	
	create_tween().tween_property($Rhand, "rotation_degrees", 70 + (360 * 2), 4)
	create_tween().tween_property($Lhand, "rotation_degrees", -70 + (360 * 2), 4)
	var pos1: Vector2 = $Rhand.global_position
	var pos2: Vector2 = $Lhand.global_position
	
	for j in range(120):
		if not is_dead:
			var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [$Rhand.rotation_degrees - 70], 0, 300, [Vector2.ZERO], 700, 1)
			var attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [$Lhand.rotation_degrees + 70], 0, 300, [Vector2.ZERO], 700, 1)
			attack1.set_abs_position([pos1])
			attack2.set_abs_position([pos2])
			
			attack1.play(self)
			await  get_tree().create_timer(0.01).timeout
			attack2.play(self)
			await  get_tree().create_timer(0.01).timeout


func boss_at3() -> void:
	create_tween().tween_property($Lhand, "global_position", Vector2(800, 300), 0.2)
	create_tween().tween_property($Lhand, "rotation_degrees", 60, 0.2)
	await  get_tree().create_timer(0.2).timeout
	
	create_tween().tween_property($Lhand, "global_position:x", 350, 2)
	var tween_y: Tween = create_tween()
	tween_y.tween_property($Lhand, "global_position:y", 350, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween_y.tween_property($Lhand, "global_position:y", 300, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	create_tween().tween_property($Lhand, "rotation_degrees", 150, 2)
	
	create_tween().tween_property($Lhand, "global_position:x", 800, 2).set_delay(2)
	tween_y.tween_property($Lhand, "global_position:y", 350, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween_y.tween_property($Lhand, "global_position:y", 300, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	create_tween().tween_property($Lhand, "rotation_degrees", 60, 2).set_delay(2)
	
	for j in range(36):
		var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [$Lhand.rotation_degrees + 70], 0, 200, [Vector2.ZERO], 700, 1)
		var pos: Vector2 = $Lhand.global_position
		attack.set_abs_position([pos])
		
		if not is_dead:
			attack.play(self)
		await  get_tree().create_timer(0.1).timeout


func shoot(bul: Node, _seconds: float, sfx: AudioStream = Audio.sfx_shoot) -> void:
	bul.set_collision_mask_value(1, true)
	if bul.wait_time > 0:
		var indicator: Node = preload("res://Scenes/indicator.tscn").instantiate()
		indicator.time = bul.wait_time
		indicator.type = bul.marker_type
		indicator.angle = bul.rotation_degrees
		indicator.position = bul.position
		get_parent().add_child(indicator)
		await get_tree().create_timer(bul.wait_time).timeout
	
	Audio.play_sfx(sfx)
	bul.z_index = -1
	get_parent().add_child(bul)


func _on_move_timer_timeout() -> void:
	var rand_mov: Vector2 = Vector2(randi_range(300, 850), randi_range(200, 300))
	var t: Tween = create_tween()
	t.tween_property(self, "position", rand_mov, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func update_status_bar() -> void:
	$StatusEffectsBar.update_status_effects(status_effects)
