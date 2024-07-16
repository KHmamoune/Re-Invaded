extends Area2D


signal dead


var hp: int = 10
var is_dead: bool = false
var scrap: int = 10
var status_effects: Dictionary = {}

@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
var attack: Card.AttackPattren


func _ready() -> void:
	$hp.text = str(hp)


func start() -> void:
	$Animations.play("idle")
	
	var start_angle: int = randi_range(0, 9)
	var arr: Array = [start_angle]
	for i in range(1, 36):
		arr.append(start_angle + (i * 10))
	
	attack = Card.AttackPattren.new(bullet, 36, 1, arr, 0.2, 400, [Vector2.ZERO], 800, 1)


func take_damage(dmg: int) -> void:
	Audio.play_sfx(Audio.sfx_hit)
	hp -= dmg
	$hp.text = str(hp)
	
	if hp <= 0 and !is_dead:
		attack.play(self)
		is_dead = true
		$Hurtbox.set_deferred("disabled", true)
		emit_signal("dead")
		queue_free()


func shoot(bul: Node, _seconds: float, sfx: AudioStream = Audio.sfx_shoot) -> void:
	bul.set_collision_mask_value(1, true)
	Audio.play_sfx(sfx)
	get_parent().call_deferred("add_child", bul)


func update_status_bar() -> void:
	$StatusEffectsBar.update_status_effects(status_effects)