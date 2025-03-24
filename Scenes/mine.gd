extends Enemy


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
var attack: Card.AttackPattren


func _ready() -> void:
	color = Color.ORANGE
	area_entered.connect(_on_area_entered)
	set_up_hp(10, Vector2(0, 50))
	set_up_status_effects(Vector2(-15, 65))
	scrap = 10
	
	var start_angle: int = randi_range(0, 9)
	var arr: Array = [start_angle]
	for i in range(1, 36):
		arr.append(start_angle + (i * 10))
	
	attack = Card.AttackPattren.new(bullet, 36, 1, arr, 0.2, 400, [Vector2.ZERO], 800, 1)


func start() -> void:
	$Animations.play("idle")


func take_damage(dmg: int, area: Node = null) -> void:
	Audio.play_sfx(Audio.sfx_hit)
	hp -= dmg
	hp_node.get_child(0).text = str(hp)
	
	if hp <= 0 and !is_dead:
		attack.play(self)
		is_dead = true
		$Hurtbox.set_deferred("disabled", true)
		
		if area != null:
			if len(area.on_kill_effects) != 0:
				for effect: Card.CardStats in area.on_kill_effects:
					var player: Node = get_tree().get_first_node_in_group("player")
					effect.play(player, self)
		
		dead.emit(scrap)
		hp_node.queue_free()
		status_node.queue_free()
		Audio.play_sfx(Audio.sfx_enemy_death_explosion)
		queue_free()


func shoot(bul: Node, _seconds: float, _i: int, _j: int, sfx: AudioStream = Audio.sfx_shoot) -> void:
	bul.set_collision_mask_value(5, true)
	Audio.play_sfx(sfx)
	get_parent().call_deferred("add_child", bul)
