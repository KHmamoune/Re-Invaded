extends Enemy


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
var awake: bool = false
var attacks: Array = [boss_at1, boss_at2, boss_at3]
var look_at_player: bool = false


func _ready() -> void:
	hp = 200
	scrap = 200
	$hp.text = str(hp)
	

func start() -> void:
	$Animations.play("idle")
	
	await jump(position + Vector2(0, 300))
	
	$ShootTimer.start()
	$MoveTimer.start()


func _process(_delta: float) -> void:
	if look_at_player:
		$Sprite/Head.look_at(get_tree().get_nodes_in_group("player")[0].global_position)
		$Sprite/Head.rotation_degrees -= 90


func _on_shoot_timer_timeout() -> void:
	$ShootTimer.stop()
	$Animations.stop()
	$MoveTimer.stop()
	
	await attacks[randi_range(0, len(attacks)-1)].call()
	
	$MoveTimer.start()
	$ShootTimer.start()
	$Animations.play("idle")


func boss_at1() -> void:
	look_at_player = true
	await get_tree().create_timer(0.1).timeout
	var j: int = 0
	
	while j < 10:
		var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [$Sprite/Head.rotation_degrees + 180], 0.2, 500, [Vector2.ZERO], 800, 1)
		attack.set_abs_position([$Sprite/Head.global_position])
		attack.set_marker("line", 0.1)
		attack.set_sprite_and_size(preload("res://Images/Bullets/splice_stinger.png"), 1, 0, Vector2(0.5, 0.5), Vector2(0.5, 0.4))
		attack.play(self)
		await  get_tree().create_timer(0.5).timeout
		j += 1
	
	look_at_player = false
	$Sprite/Head.rotation_degrees = 0


func boss_at2() -> void:
	await jump(Vector2(575, 100))
	create_tween().tween_property($Sprite/Head, "rotation_degrees", 90, 1)
	
	var j: int = 0
	while j < 10:
		await get_tree().create_timer(0.09).timeout
		var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [$Sprite/Head.rotation_degrees + 180], 0.2, 500, [Vector2.ZERO], 1500, 1)
		attack.set_properties(true)
		attack.set_sprite_and_size(preload("res://Images/Bullets/splice_stinger.png"), 1, 0, Vector2(0.5, 0.5), Vector2(0.5, 0.4))
		attack.set_abs_position([$Sprite/Head.global_position])
		attack.play(self)
		j += 1
	
	$Sprite/Head.rotation_degrees = 0
	create_tween().tween_property($Sprite/Head, "rotation_degrees", -90, 1)
	await get_tree().create_timer(0.2).timeout
	
	j = 0
	while j < 10:
		await get_tree().create_timer(0.09).timeout
		var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [$Sprite/Head.rotation_degrees + 180], 0.2, 500, [Vector2.ZERO], 1500, 1)
		attack.set_properties(true)
		attack.set_sprite_and_size(preload("res://Images/Bullets/splice_stinger.png"), 1, 0, Vector2(0.5, 0.5), Vector2(0.5, 0.4))
		attack.set_abs_position([$Sprite/Head.global_position])
		attack.play(self)
		j += 1
	
	$Sprite/Head.rotation_degrees = 0
	await get_tree().create_timer(1).timeout


func boss_at3() -> void:
	await jump(Vector2(575, 100))
	look_at_player = true
	await get_tree().create_timer(0.1).timeout
	var j: int = 0
	
	while j < 15:
		var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [$Sprite/Head.rotation_degrees + 180], 0.2, 600, [Vector2.ZERO], 800, 1)
		attack.set_abs_position([$Sprite/Head.global_position])
		attack.set_aim("", 40)
		attack.set_sprite_and_size(preload("res://Images/Bullets/splice_stinger.png"), 1, 0, Vector2(0.5, 0.5), Vector2(0.5, 0.4))
		attack.play(self)
		await  get_tree().create_timer(0.2).timeout
		j += 1
	
	look_at_player = false
	$Sprite/Head.rotation_degrees = 0


func _on_move_timer_timeout() -> void:
	var rand_mov: Vector2 = Vector2(randi_range(300, 850), randi_range(200, 300))
	jump(rand_mov)


func jump(mov: Vector2) -> void:
	$Animations.play("jump")
	var t: Tween = create_tween()
	t.tween_property(self, "position", mov, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await t.finished


func hit_flash() -> void:
	$Sprite/Body.material.set_shader_parameter("flash_modifier", 1)
	$Sprite/Head.material.set_shader_parameter("flash_modifier", 1)
	await get_tree().create_timer(0.02).timeout
	$Sprite/Body.material.set_shader_parameter("flash_modifier", 0)
	$Sprite/Head.material.set_shader_parameter("flash_modifier", 0)


func update_status_bar() -> void:
	$StatusEffectsBar.update_status_effects(status_effects)
